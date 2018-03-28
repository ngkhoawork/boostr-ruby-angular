class DealProductBudget < ActiveRecord::Base
  belongs_to :deal_product
  delegate :deal, to: :deal_product

  scope :for_time_period, -> (start_date, end_date) { where('deal_product_budgets.start_date <= ? AND deal_product_budgets.end_date >= ?', end_date, start_date) }
  scope :for_product_id, -> (product_id) { where('deal_products.product_id = ?', product_id) if product_id.present? }
  scope :by_seller_id, -> (seller_id) do
    joins(deal_product: { deal: :deal_members })
    .where(deal_members: { user_id: seller_id }) if seller_id.present?
  end
  scope :by_team_id, -> (team_id) do
    joins( deal_product: { deal: { deal_members: :user } } )
      .where(users: { team_id: team_id }) if team_id.present?
  end
  scope :by_created_date, -> (start_date, end_date) do
    where(deals: { created_at: (start_date.to_datetime.beginning_of_day)..(end_date.to_datetime.end_of_day) }) if start_date.present? && end_date.present?
  end
  scope :all_products, -> do
    joins(deal_product: { deal: :stage })
    .where('(deals.open IS true) OR (stages.open IS false AND stages.probability=0)')
  end

  validates :start_date, :end_date, presence: true

  def daily_budget
    budget / (end_date - start_date + 1).to_f
  end

  def budget_percentage
    return ((budget_loc || 0).to_f / deal_product.budget_loc.to_f * 100).round if budget_loc && deal_product.budget_loc && deal_product.budget_loc > 0
    return 0
  end

  def update_local_budget(exchange_rate)
    self.update(budget_loc: budget * exchange_rate)
  end

  def self.to_csv(company_id)
    header = [
      :Deal_Id,
      :Deal_Name,
      :Deal_Percentage,
      :Advertiser,
      :Product,
      :Budget,
      :Start_Date,
      :End_Date,
      :Budget_USD
    ]
    deal_product_cf_names = Company.find(company_id).deal_product_cf_names.where("disabled IS NOT TRUE").order("position asc")
    deal_product_cf_names.each do |deal_product_cf_name|
      header << deal_product_cf_name.field_label
    end

    CSV.generate(headers: true) do |csv|
      csv << header

      deals = Deal.where(company_id: company_id)
      .includes(:products, :deal_products, :deal_product_budgets, :stage, :advertiser)
      .order(:id)

      deals.each do |deal|
        deal.deal_products.each do |deal_product|
          custom_field_line = []
          deal_product_cf = deal_product.deal_product_cf.as_json
          deal_product_cf_names.each do |deal_product_cf_name|
            field_name = deal_product_cf_name.field_type + deal_product_cf_name.field_index.to_s
            value = nil
            if deal_product_cf.present?
              value = deal_product_cf[field_name]
            end
            # line << value

            case deal_product_cf_name.field_type
              when "currency"
                custom_field_line << '$' + (value || 0).to_s
              when "percentage"
                custom_field_line << (value || 0).to_s + "%"
              when "number", "integer"
                custom_field_line << (value || 0)
              when "datetime"
                custom_field_line << (value.present? ? (value.strftime("%Y-%m-%d %H:%M:%S")) : 'N/A')
              else
                custom_field_line << (value || 'N/A')
            end
          end
          deal_product.deal_product_budgets.each do |dpb|
            line = []
            line << deal.id
            line << deal.name
            line << (deal.stage.present? ? deal.stage.probability : nil)
            line << deal.advertiser.try(:name)
            line << deal_product.product.name
            line << (dpb.budget_loc.try(:round) || 0)
            line << dpb.start_date
            line << dpb.end_date
            line << (dpb.budget.try(:round) || 0)
            line += custom_field_line
            csv << line
          end
        end
      end
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'deal_product_budget', source: 'ui')
    import_log.set_file_source(file_path)

    Deal.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:destroy, :after, :update_pipeline_fact_callback)

    deal_change = {time_period_ids: [], product_ids: [], stage_ids: [], user_ids: []}

    CSV.parse(file, headers: true) do |row|
      import_log.count_processed

      if row[0]
        begin
          deal = current_user.company.deals.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          import_log.count_failed
          import_log.log_error(["Deal ID #{row[0]} could not be found"])
          next
        end
      end

      if row[1]
        if !(deal)
          deals = current_user.company.deals.where('name ilike ?', row[1].strip)
          if deals.length > 1
            import_log.count_failed
            import_log.log_error(["Deal Name #{row[1]} matched more than one deal record"])
            next
          elsif deals.length < 1
            import_log.count_failed
            import_log.log_error(["Deal Name #{row[1]} did not match any Deal record"])
            next
          end
          deal = deals.first
        end
      else
        import_log.count_failed
        import_log.log_error(["Deal Name can't be blank"])
        next
      end

      if row[2]
        full_name = row[2].to_s + ' ' + row[3].to_s + ' ' + row[4].to_s
        product = current_user.company.products.where(full_name: full_name.strip).first
        unless product
          import_log.count_failed
          import_log.log_error(["Product #{full_name.strip} could not be found"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Deal Product can't be blank"])
        next
      end

      budget = nil
      if row[5]
        budget = Float(row[5].strip) rescue false
        budget_loc = budget
        unless budget
          import_log.count_failed
          import_log.log_error(["Budget must be a numeric value"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Budget can't be blank"])
        next
      end

      if deal.exchange_rate
        budget = budget_loc / deal.exchange_rate
      else
        import_log.count_failed
        import_log.log_error(["No active exchange rate for #{deal.curr_cd} at #{Date.today.strftime("%m/%d/%Y")}"])
        next
      end

      if row[6]
        begin
          period = Date.strptime(row[6].strip, '%b-%y')
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['Period must be in valid format: Mon-YY'])
          next
        end

        unless period.between?(deal.start_date.beginning_of_month, deal.end_date.end_of_month)
          import_log.count_failed
          import_log.log_error(["Period #{row[6]} must be within Deal Period"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Period can't be blank"])
        next
      end

      deal_product_budget_params = {
        budget: budget,
        budget_loc: budget_loc,
        start_date: period.beginning_of_month,
        end_date: period.end_of_month
      }

      deal_product = deal.deal_products.where(product: product).first

      if !(deal_product)
        deal_product = deal.deal_products.new(product: product)
        deal_product_is_new = true
      else
        deal_product_budget_params[:deal_product_id] = deal_product.id

        deal_product_budgets = deal_product.deal_product_budgets.where("DATE_PART('year', start_date) = ? and DATE_PART('month', start_date) = ?", period.year, period.month)
        if deal_product_budgets.any?
          deal_product_budget_params[:id] = deal_product_budgets.first.id
        elsif deal_product.deal_product_budgets.count >= deal.months.length
          import_log.count_failed
          import_log.log_error(["Deal Product #{row[2].strip} is full of monthly budgets"])
          next
        end
      end

      deal_change[:time_period_ids] += TimePeriod.where("end_date >= ? and start_date <= ?", deal.start_date, deal.end_date).collect{|item| item.id}
      deal_change[:stage_ids] += [deal.stage_id] if deal.stage_id.present?
      deal_change[:user_ids] += deal.deal_members.collect{|item| item.user_id}
      deal_change[:product_ids] += [deal_product.product_id]

      if deal_product.update_attributes(deal_product_budgets_attributes: [deal_product_budget_params])
        import_log.count_imported

        deal_product.update_budget if deal_product_is_new
        DealTotalBudgetUpdaterService.perform(deal_product.deal) if deal_product_is_new
      else
        import_log.count_failed
        import_log.log_error(deal_product.errors.full_messages)
        next
      end
    end

    Deal.set_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.set_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.set_callback(:destroy, :after, :update_pipeline_fact_callback)

    deal_change[:time_period_ids] = deal_change[:time_period_ids].uniq
    deal_change[:user_ids] = deal_change[:user_ids].uniq
    deal_change[:product_ids] = deal_change[:product_ids].uniq
    deal_change[:stage_ids] = deal_change[:stage_ids].uniq

    ForecastPipelineCalculatorWorker.perform_async(deal_change)

    import_log.save
  end
end
