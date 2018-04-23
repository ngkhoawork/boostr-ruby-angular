class DealProduct < ActiveRecord::Base
  SAFE_COLUMNS = %i{budget created_at updated_at budget_loc ssp_deal_id pmp_type}

  belongs_to :deal, touch: true
  belongs_to :product
  belongs_to :ssp
  has_many :deal_product_budgets, -> { order(:start_date) }, dependent: :destroy
  has_one :deal_product_cf, dependent: :destroy

  enum pmp_type: PMP_TYPES

  validates :product, presence: true
  validates :budget, :budget_loc, numericality: true
  validate :active_exchange_rate

  accepts_nested_attributes_for :deal_product_budgets
  accepts_nested_attributes_for :deal_product_cf

  before_validation :ensure_budget_attributes_have_values

  after_create do
    if deal_product_budgets.empty?
      self.create_product_budgets
    end
  end

  after_update do
    if deal_product_budgets.sum(:budget_loc) != budget_loc || deal_product_budgets.sum(:budget) != budget
      if budget_loc_changed? || budget_changed?
        self.update_product_budgets
      else
        self.update_budget
        should_update_deal_budget = true
      end
    end

    if should_update_deal_budget
      DealTotalBudgetUpdaterService.perform(deal)
    end
  end

  after_destroy do |deal_product|
    update_forecast_pipeline_product(deal_product)
  end

  set_callback :save, :after, :update_pipeline_fact_callback

  scope :product_type_of, -> (type) { joins(:product).where("products.revenue_type = ?", type) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) if product_id.present? }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) if product_ids.present? }
  scope :open, ->  { where('deal_products.open IS true')  }
  scope :active, -> { DealProduct.joins('LEFT JOIN products ON deal_products.product_id = products.id').where('products.active IS true') }
  scope :created_asc, -> { order(:created_at) }

  def update_pipeline_fact_callback
    update_forecast_pipeline_product(self) if budget_changed? || budget_loc_changed? || open_changed?
  end

  def daily_budget
    budget / (deal.end_date - deal.start_date + 1).to_f
  end

  def daily_budget_loc
    budget_loc / (deal.end_date - deal.start_date + 1).to_f
  end

  def local_currency_budget_in_usd
    budget_loc / deal.exchange_rate
  end

  def update_forecast_pipeline_product(deal_product)
    deal = deal_product.deal
    company = deal.company
    stage = deal.stage
    product = deal_product.product
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", deal.start_date, deal.end_date)
    time_periods.each do |time_period|
      deal.users.each do |user|
        forecast_pipeline_fact_calculator = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
        forecast_pipeline_fact_calculator.calculate()
      end
    end
  end

  def active_exchange_rate
    if deal && deal.curr_cd != 'USD'
      unless deal.company.active_currencies.include?(deal.curr_cd)
        errors.add(:curr_cd, "#{deal.curr_cd} does not have an active exchange rate")
      end
    end
  end

  def create_product_budgets
    last_index = deal.months.count - 1
    total = 0
    total_loc = 0

    deal_start_date = deal.start_date
    deal_end_date = deal.end_date

    deal.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * deal.days_per_month[index]).round(0)
        monthly_budget = 0 if monthly_budget.between?(0, 1)
        total += monthly_budget

        monthly_budget_loc = (daily_budget_loc * deal.days_per_month[index]).round(0)
        monthly_budget_loc = 0 if monthly_budget_loc.between?(0, 1)
        total_loc += monthly_budget_loc
      end
      period = Date.new(*month)
      deal_product_budgets.create(
        start_date: [period, deal_start_date].max,
        end_date: [period.end_of_month, deal_end_date].min,
        budget: monthly_budget,
        budget_loc: monthly_budget_loc
      )
    end
  end

  def update_product_budgets
    last_index = deal_product_budgets.count - 1
    total = 0
    total_loc = 0

    deal_product_budgets.each_with_index do |deal_product_budget, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * deal.days_per_month[index])
        monthly_budget = 0 if monthly_budget.between?(0, 1)
        total += monthly_budget.round(0)

        monthly_budget_loc = (daily_budget_loc * deal.days_per_month[index])
        monthly_budget_loc = 0 if monthly_budget_loc.between?(0, 1)
        total_loc += monthly_budget_loc.round(0)
      end
      deal_product_budget.update(budget: monthly_budget.round(0), budget_loc: monthly_budget_loc.round(0))
    end
  end

  def update_budget
    new_budget = deal_product_budgets.sum(:budget)
    new_budget_loc = deal_product_budgets.sum(:budget_loc)
    self.update(budget: new_budget, budget_loc: new_budget_loc)
  end

  def update_periods
    deal_product_budgets.each_with_index do |deal_product_budget, index|
      period = Date.new(*deal.months[index])
      deal_product_budget.start_date = [period, deal.start_date].max
      deal_product_budget.end_date = [period.end_of_month, deal.end_date].min
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'deal_product', source: 'ui')
    import_log.set_file_source(file_path)

    @custom_field_names = current_user.company.deal_product_cf_names

    Deal.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:destroy, :after, :update_pipeline_fact_callback)

    deal_change = {time_period_ids: [], product_ids: [], stage_ids: [], user_ids: []}

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed
      @has_custom_field_rows ||= (row.headers && @custom_field_names.map(&:to_csv_header)).any?

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

      i = 0
      if row[2]
        full_name = row[2].to_s
        if current_user.company.product_options_enabled
          if current_user.company.product_option1_enabled
            i += 1
            full_name += ' ' + row[3].to_s
          end
          if current_user.company.product_option2_enabled
            i += 1
            full_name += ' ' + row[4].to_s
          end
        end
        product = current_user.company.products.where(full_name: full_name.strip).first
        unless product
          import_log.count_failed
          import_log.log_error(["Product #{full_name.strip} could not be found"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Product can't be blank"])
        next
      end

      budget = nil
      if row[3+i]
        budget = Float(row[3+i].strip) rescue false
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

      deal_product_params = {
        deal_id: deal.id,
        budget: budget,
        budget_loc: budget_loc,
        product_id: product.id
      }

      deal_product = deal.deal_products.find_by(product: product)

      if deal.present?
        deal_change[:time_period_ids] += current_user.company.time_periods.for_time_period(deal.start_date, deal.end_date).collect(&:id)
        deal_change[:stage_ids] += [deal.stage_id] if deal.stage_id.present?
        deal_change[:user_ids] += deal.deal_members.collect{|item| item.user_id}
        deal_change[:product_ids] += deal.deal_products.collect{|item| item.product_id}
      end
      deal_change[:product_ids] += [product.id]

      if !(deal_product)
        deal_change[:time_period_ids] += current_user.company.time_periods.for_time_period(deal.start_date, deal.end_date).collect(&:id)
        deal_change[:stage_ids] += [deal.stage_id] if deal.stage_id.present?
        deal_change[:user_ids] += deal.deal_members.collect{|item| item.user_id}
        deal_change[:product_ids] += [product.id]
        deal_product = deal.deal_products.new
      elsif (deal_product.budget != budget || deal_product.budget_loc != budget_loc)
        deal_change[:time_period_ids] += current_user.company.time_periods.for_time_period(deal.start_date, deal.end_date).collect(&:id)
        deal_change[:stage_ids] += [deal.stage_id] if deal.stage_id.present?
        deal_change[:user_ids] += deal.deal_members.collect{|item| item.user_id}
        deal_change[:product_ids] += [product.id]
      end

      if deal_product.update_attributes(deal_product_params)
        import_log.count_imported

        DealTotalBudgetUpdaterService.perform(deal_product.deal)

        import_custom_field(deal_product, row) if @has_custom_field_rows
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

  def upsert_custom_fields(params)
    if self.deal_product_cf.present?
      self.deal_product_cf.update(params)
    else
      cf = self.build_deal_product_cf(params)
      cf.save
    end
  end

  private

  def ensure_budget_attributes_have_values
    self.budget = 0 if budget.nil?
    self.budget_loc = 0 if budget_loc.nil?
  end

  def self.import_custom_field(obj, row)
    params = {}

    @custom_field_names.each do |cf|
      params[cf.field_name] = row[cf.to_csv_header]
    end

    if params.compact.any?
      obj.upsert_custom_fields(params)
    end
  end
end
