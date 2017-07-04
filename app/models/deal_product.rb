class DealProduct < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :product
  has_many :deal_product_budgets, -> { order(:start_date) }, dependent: :destroy
  has_one :deal_product_cf, dependent: :destroy

  validates :product, presence: true
  validate :active_exchange_rate

  accepts_nested_attributes_for :deal_product_budgets
  accepts_nested_attributes_for :deal_product_cf

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
      deal.update_total_budget
    end
  end

  scope :product_type_of, -> (type) { joins(:product).where("products.revenue_type = ?", type) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) if product_ids.present? }
  scope :open, ->  { where('deal_products.open IS true')  }
  scope :active, -> { DealProduct.joins('LEFT JOIN products ON deal_products.product_id = products.id').where('products.active IS true') }

  def daily_budget
    budget / (deal.end_date - deal.start_date + 1).to_f
  end

  def daily_budget_loc
    budget_loc / (deal.end_date - deal.start_date + 1).to_f
  end

  def local_currency_budget_in_usd
    budget_loc / deal.exchange_rate
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

      if row[2]
        product = current_user.company.products.where('name ilike ?', row[2]).first
        unless product
          import_log.count_failed
          import_log.log_error(["Product #{row[2]} could not be found"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Product can't be blank"])
        next
      end

      budget = nil
      if row[3]
        budget = Float(row[3].strip) rescue false
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

      if !(deal_product)
        deal_product = deal.deal_products.new
      end

      if deal_product.update_attributes(deal_product_params)
        import_log.count_imported

        deal_product.deal.update_total_budget

        import_custom_field(deal_product, row) if @has_custom_field_rows
      else
        import_log.count_failed
        import_log.log_error(deal_product.errors.full_messages)
        next
      end
    end

    import_log.save
  end

  def self.to_csv
    header = [
      :Deal_id,
      :Deal_name,
      :Advertiser,
      :Agency,
      :Deal_stage,
      :Deal_probability,
      :Deal_start_date,
      :Deal_end_date,
      :Deal_currency,
      :Product_name,
      :Product_budget,
      :Product_budget_USD
    ]

    CSV.generate(headers: true) do |csv|
      csv << header

      all.includes(
        :product,
        deal: [:advertiser, :agency, :stage]
      )
      .order(:deal_id, :id).each do |deal_product|
        line = []
        line << deal_product.deal.id
        line << deal_product.deal.name
        line << deal_product.deal.advertiser.try(:name)
        line << deal_product.deal.agency.try(:name)
        line << deal_product.deal.stage.try(:name)
        line << deal_product.deal.stage.try(:probability)
        line << deal_product.deal.start_date
        line << deal_product.deal.end_date
        line << deal_product.deal.curr_cd
        line << deal_product.product.try(:name)
        line << deal_product.budget
        line << deal_product.budget_loc

        csv << line
      end
    end
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
