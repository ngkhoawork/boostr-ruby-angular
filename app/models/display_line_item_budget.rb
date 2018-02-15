class DisplayLineItemBudget < ActiveRecord::Base
  PENDING = 'Pending'.freeze
  BUDGET_BUFFER = 10

  belongs_to :display_line_item
  delegate :io, to: :display_line_item

  scope :for_time_period, -> (start_date, end_date) { where('display_line_item_budgets.start_date <= ? AND display_line_item_budgets.end_date >= ?', end_date, start_date) }

  scope :by_date, -> (start_date, end_date) do
    where('display_line_item_budgets.start_date <= ? AND display_line_item_budgets.end_date >= ?', start_date, end_date)
  end

  scope :for_product_id, -> (product_id) do
    where('display_line_items.product_id = ?', product_id) if product_id.present?
  end
  scope :by_seller_id, -> (seller_id) do
    joins(display_line_item: { io: :io_members })
    .where(io_members: { user_id: seller_id }) if seller_id.present?
  end
  scope :by_team_id, -> (team_id) do
    joins(display_line_item: { io: { io_members: :user } })
      .where(users: { team_id: team_id }) if team_id.present?
  end
  scope :by_created_date, -> (start_date, end_date) do
    where(ios: { created_at: (start_date.to_datetime.beginning_of_day)..(end_date.to_datetime.end_of_day) }) if start_date.present? && end_date.present?
  end

  attr_accessor :has_dfp_budget_correction

  before_save :correct_budget, if: -> { has_dfp_budget_correction }
  before_save :set_cpd_price_type_budget, if: -> { has_dfp_budget_correction }

  set_callback :save, :after, :update_revenue_fact_callback

  validate :sum_of_budgets_within_line_item, unless: -> { has_dfp_budget_correction }

  def update_revenue_fact_callback
    if budget_changed?
      update_revenue_pipeline_budget(self)
    end
  end

  def update_revenue_pipeline_budget(display_line_item_budget)
    display_line_item = display_line_item_budget.display_line_item
    io = display_line_item.io
    product = display_line_item.product
    if io.present? && product.present?
      company = io.company
      time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
          forecast_revenue_fact_calculator.calculate()
        end
      end
    end
  end

  def daily_budget
    if effective_days > 0
      budget.to_f / effective_days
    else
      0
    end
  end

  def daily_budget_loc
    if effective_days > 0
      budget_loc.to_f / effective_days
    else
      0
    end
  end

  def self.to_csv(company_id)
    header = [
      :IO_Num,
      :IO_Name,
      :Advertiser,
      :Product,
      :Budget,
      :Start_Date,
      :End_Date,
      :Revenue_Type,
      :Budget_USD
    ]

    CSV.generate(headers: true) do |csv|
      csv << header

      ios = Io.where(company_id: company_id).includes(:advertiser, {display_line_items: :product}, :display_line_item_budgets, {content_fees: :product}, :content_fee_product_budgets)
      ios.each do |io|
        io.content_fees.each do |content_fee|
          content_fee.content_fee_product_budgets.each do |cfpb|
            line = []
            line << io.io_number
            line << io.name
            line << io.advertiser.try(:name)
            line << content_fee.product.try(:name)
            line << (cfpb.budget_loc.try(:round) || 0)
            line << cfpb.start_date
            line << cfpb.end_date
            line << content_fee.product.try(:revenue_type)
            line << (cfpb.budget.try(:round) || 0)

            csv << line
          end
        end

        io.display_line_items.each do |display_line_item|
          display_line_item.display_line_item_budgets.each do |dlib|
            budget_loc = dlib.budget_loc || (display_line_item.budget_loc.to_f / (display_line_item.end_date - display_line_item.start_date + 1).to_i) * ((dlib.end_date - dlib.start_date + 1).to_i)
            budget_usd = dlib.budget || (display_line_item.budget.to_f / (display_line_item.end_date - display_line_item.start_date + 1).to_i) * ((dlib.end_date - dlib.start_date + 1).to_i)
            line = []
            line << io.io_number
            line << io.name
            line << io.advertiser.try(:name)
            line << display_line_item.product.try(:name)
            line << (budget_loc.try(:round) || 0)
            line << dlib.start_date
            line << dlib.end_date
            line << display_line_item.product.try(:revenue_type)
            line << (budget_usd.try(:round) || 0)

            csv << line
          end
        end
      end
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'display_line_item_budget', source: 'ui')
    import_log.set_file_source(file_path)

    io_change = {time_period_ids: [], product_ids: [], user_ids: []}

    Io.skip_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItem.skip_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItemBudget.set_callback(:save, :after, :update_revenue_fact_callback)

    CSV.parse(file, headers: true) do |row|
      import_log.count_processed

      io_id = nil
      io = nil
      external_io_number = nil

      if row[0]
        external_io_number = row[0].strip
        ios = current_user.company.ios.where("external_io_number = ?", row[0].strip)
        if ios.count > 0
          io_id = ios[0].id
          io = ios[0]

          unless io.exchange_rate
            import_log.count_failed
            import_log.log_error(["No exchange rate for #{io.curr_cd} found at #{io.created_at.strftime("%m/%d/%Y")}"])
            next
          end
        else
          import_log.count_failed
          import_log.log_error(["Ext IO Num doesn't match with any IO."])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Ext IO Num can't be blank"])
        next
      end

      display_line_item = nil
      if row[1]
        display_line_item_num = row[1].strip
        display_line_items = io.display_line_items.where(line_number: display_line_item_num)
        if display_line_items.count > 0
          display_line_item = display_line_items[0]
        else
          import_log.count_failed
          import_log.log_error(["Display Line Number doesn't match with any display line items."])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Display Line Number can't be blank"])
        next
      end

      budget = nil
      budget_loc = nil
      if row[2]
        budget = Float(row[2].strip) rescue false
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

      start_date = nil
      if row[3].present?
        begin
          start_date = Date.strptime(row[3].strip, "%m/%d/%Y")
          if start_date.year < 100
            start_date = Date.strptime(row[3].strip, "%m/%d/%y")
          end

        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['Start Date must be a valid datetime'])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(['Start Date must be present'])
        next
      end

      end_date = nil
      if row[4].present?
        begin
          end_date = Date.strptime(row[4].strip, "%m/%d/%Y")
          if end_date.year < 100
            end_date = Date.strptime(row[4].strip, "%m/%d/%y")
          end
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['End Date must be a valid datetime'])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(['End Date must be present'])
        next
      end

      if (end_date && start_date) && start_date > end_date
        import_log.count_failed
        import_log.log_error(['Start Date must preceed End Date'])
        next
      end

      display_line_item_budget_params = {
          external_io_number: external_io_number,
          budget: budget,
          budget_loc: budget_loc,
          start_date: start_date,
          end_date: end_date,
      }

      if io.present?
        io_change[:time_period_ids] += TimePeriod.where("end_date >= ? and start_date <= ?", [io.start_date, start_date].min, [io.end_date, end_date].max).collect{|item| item.id}
        io_change[:user_ids] += io.users.collect{|item| item.id}
        io_change[:product_ids] += io.products.collect{|item| item.id}
      end

      display_line_item_budget_params = self.convert_params_currency(io.exchange_rate, display_line_item_budget_params)

      display_line_item_budgets = display_line_item.display_line_item_budgets.where("date_part('year', start_date) = ? and date_part('month', start_date) = ?", start_date.year, start_date.month)
      if display_line_item_budgets.count > 0
        display_line_item_budget = display_line_item_budgets[0]

        import_log.count_imported
        display_line_item_budget.update_attributes(display_line_item_budget_params)
      else
        import_log.count_imported
        display_line_item.display_line_item_budgets.create(display_line_item_budget_params)
      end
    end

    Io.set_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItem.set_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItemBudget.set_callback(:save, :after, :update_revenue_fact_callback)

    io_change[:time_period_ids] = io_change[:time_period_ids].uniq
    io_change[:user_ids] = io_change[:user_ids].uniq
    io_change[:product_ids] = io_change[:product_ids].uniq

    ForecastRevenueCalculatorWorker.perform_async(io_change)

    import_log.save
  end

  private

  def effective_days
    @effective_days ||= ([display_line_item.end_date, end_date].min - [display_line_item.start_date, start_date].max + 1).to_i
  end

  def self.convert_params_currency(exchange_rate, params)
    params[:budget] = params[:budget_loc] / exchange_rate
    params
  end

  def sum_of_budgets_within_line_item
    return unless budget_loc.present?

    if max_monthly_budget_exceeded?
      errors.add(:budget, 'sum of monthly budgets can\'t be more then line item budget')
    end
  end

  def correct_budget
    if max_monthly_budget_exceeded?
      self.budget_loc = corrected_budget
      self.budget = corrected_budget
      display_line_item.budget_delivered_loc = corrected_budget
      display_line_item.budget_remaining_loc = 0
    end
  end

  def corrected_budget
    @corrected_budget ||= display_line_item.budget_loc - opposite_sum_of_display_line_item_budgets
  end

  def set_cpd_price_type_budget
    self.budget_loc = display_line_item.budget_loc if display_line_item.is_cpd_price_type?
  end

  def max_monthly_budget_exceeded?
    return sum_of_monthly_budgets > display_line_item.budget_loc if has_dfp_budget_correction
    sum_of_monthly_budgets > (display_line_item.budget_loc + BUDGET_BUFFER)
  end

  def sum_of_monthly_budgets
    (opposite_sum_of_display_line_item_budgets + budget_loc.truncate(2))
  end

  def opposite_sum_of_display_line_item_budgets
    display_line_item.display_line_item_budgets.where.not(id: self.id).sum(:budget_loc)
  end
end
