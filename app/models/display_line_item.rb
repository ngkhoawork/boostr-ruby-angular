class DisplayLineItem < ActiveRecord::Base
  belongs_to :io
  belongs_to :product
  belongs_to :temp_io

  has_many :display_line_item_budgets, dependent: :destroy

  has_one :request, as: :requestable, dependent: :destroy

  scope :without_budgets_by_date, -> (start_date, end_date) do
    joins(:display_line_item_budgets)
    .where
    .not('display_line_item_budgets.start_date <= ? AND display_line_item_budgets.end_date >= ?', start_date, end_date)
  end

  scope :with_budgets_by_date, -> (start_date, end_date) do
    joins(:display_line_item_budgets)
    .where('display_line_item_budgets.start_date <= ? AND display_line_item_budgets.end_date >= ?',
           start_date,
           end_date)
  end

  scope :without_display_line_item_budgets, -> do
    includes(:display_line_item_budgets).where(display_line_item_budgets: { id: nil })
  end

  scope :by_period, -> (start_date, end_date) do
    where('display_line_items.start_date <= ? AND display_line_items.end_date >= ?', start_date, end_date)
  end

  scope :by_period_without_budgets, -> (start_date, end_date, io_ids) do
    includes(:product, io: [:deal, :advertiser, :agency])
    .by_period(start_date, end_date)
    .where(io: io_ids)
    .without_budgets_by_date(start_date, end_date).uniq
  end

  scope :by_period_with_budgets, -> (start_date, end_date, io_ids) do
    includes(:product, io: [:deal, :advertiser, :agency])
    .by_period(start_date, end_date)
    .where(io: io_ids)
    .with_budgets_by_date(start_date, end_date).uniq
  end

  scope :by_period_without_display_line_item_budgets, -> (start_date, end_date, io_ids) do
    includes(:product, io: [:deal, :advertiser, :agency])
    .where(io: io_ids)
    .by_period(start_date, end_date)
    .without_display_line_item_budgets
  end
  scope :by_start_date, -> (start_date, end_date) do
    where(start_date: start_date..end_date) if (start_date && end_date).present?
  end
  scope :by_io_name, -> (name) { joins(:io).where('ios.name ilike ?', "%#{name}%") if name.present? }
  scope :by_agency_name, -> (name) { joins(io: :agency).where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_advertiser_name, -> (name) do
    joins(io: :advertiser).where('clients.name ilike ?', "%#{name}%") if name.present?
  end

  attr_accessor :dont_update_parent_budget
  attr_accessor :override_budget_delivered

  before_create do
    correct_budget_remaining
    set_alert
  end

  before_update do
    reset_budget_delivered unless override_budget_delivered
    correct_budget_remaining
    set_alert
  end

  before_save :remove_budgets_out_of_dates, if: -> { start_date_changed? || end_date_changed? }

  after_save do
    update_io_budget
    close_deal_products
  end

  after_destroy do |display_line_item|
    update_revenue_pipeline_budget(display_line_item)
  end

  set_callback :save, :after, :update_revenue_fact_callback

  after_commit :update_temp_io_budget, on: [:create, :update]

  scope :for_time_period, -> (start_date, end_date) { where('display_line_items.start_date <= ? AND display_line_items.end_date >= ?', end_date, start_date) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) if product_id.present? }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) }

  def remove_budgets_out_of_dates
    display_line_item_budgets.outside_time_period(start_date, end_date).destroy_all
  end

  def correct_budget_remaining
    self.budget_delivered     = budget_delivered || 0
    self.budget_delivered_loc = budget_delivered_loc || 0
    self.budget_remaining     = [(budget || 0) - budget_delivered, 0].max
    self.budget_remaining_loc = [(budget_loc || 0)- budget_delivered_loc, 0].max
  end

  def reset_budget_delivered
    self.budget_delivered     = self.budget_delivered_was
    self.budget_delivered_loc = self.budget_delivered_loc_was
  end
  
  def update_io_budget
    io.update_total_budget if !dont_update_parent_budget && budget_changed? && io
  end

  def close_deal_products
    io.deal.close_display_product if io_id_changed? && io.present?
  end

  def update_revenue_fact_callback
    update_revenue_pipeline_budget(self) if budget_changed? || budget_loc_changed?
    if io_id_changed?
      if io_id_was.present?
        old_io = Io.find(io_id_was)
        update_revenue_pipeline_io(old_io) if old_io.present?
      end
      update_revenue_pipeline_io(io)
    end
    if product_id_changed?
      if product_id_was.present?
        old_product = Product.find(product_id_was)
        update_revenue_pipeline_product(old_product) if old_product.present?
      end
      update_revenue_pipeline_product(product)
    end
  end

  def update_revenue_pipeline_io(io_item)
    product = self.product
    if io_item.present? && product.present?
      company = io_item.company
      time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io_item.start_date, io_item.end_date)
      time_periods.each do |time_period|
        io_item.users.each do |user|
          forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
          forecast_revenue_fact_calculator.calculate()
        end
      end
    end
  end

  def update_revenue_pipeline_budget(display_line_item)
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

  def update_revenue_pipeline_product(product)
    io = self.io
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

  def update_temp_io_budget
    return if dont_update_parent_budget

    if temp_io
      budget = temp_io.display_line_items.sum(:budget)
      budget_loc = budget / temp_io.exchange_rate
      temp_io.update_columns(budget: budget, budget_loc: budget_loc)
    end
  end

  def set_alert(should_save=false)
    if !budget.nil? && !budget_remaining.nil?
      if budget > 0 && start_date < DateTime.now && DateTime.now < end_date
        self.daily_run_rate = ((budget - budget_remaining)/(DateTime.now.to_date-start_date.to_date+1))
        self.daily_run_rate_loc = ((budget_loc - budget_remaining_loc)/(DateTime.now.to_date-start_date.to_date+1))
        if self.daily_run_rate != 0
          self.num_days_til_out_of_budget = budget_remaining/(self.daily_run_rate)
          self.balance = ((end_date.to_date-DateTime.now.to_date+1)-self.num_days_til_out_of_budget)*(self.daily_run_rate)
          self.balance_loc = ((end_date.to_date-DateTime.now.to_date+1)-self.num_days_til_out_of_budget)*(self.daily_run_rate_loc)
        else
          self.num_days_til_out_of_budget = 0
          self.balance = 0
          self.balance_loc = 0
        end
      else
        self.daily_run_rate = 0
        self.daily_run_rate_loc = 0
        self.num_days_til_out_of_budget = 0
        self.balance = 0
        self.balance_loc = 0
      end
      self.last_alert_at = DateTime.now
    else
      self.daily_run_rate = 0
      self.daily_run_rate_loc = 0
      self.num_days_til_out_of_budget = 0
      self.balance = 0
      self.balance_loc = 0
    end
    self.save if should_save
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    list_of_currencies = Currency.pluck(:curr_cd)

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'display_line_item', source: 'ui')
    import_log.set_file_source(file_path)

    io_change = {time_period_ids: [], product_ids: [], user_ids: []}
    deal_change = {time_period_ids: [], product_ids: [], stage_ids: [], user_ids: []}

    Io.skip_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItem.skip_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItemBudget.skip_callback(:save, :after, :update_revenue_fact_callback)

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
        end
      else
        import_log.count_failed
        import_log.log_error(["Ext IO Num can't be blank"])
        next
      end

      io_name = nil
      if row[1]
        names = row[1].split('_')
        if (names.count > 1)
          if io_id.nil?
            ios = current_user.company.ios.where("io_number = ?", names[-1].strip)
            if (ios.count > 0)
              io_id = ios[0].id
              io = ios[0]
              io_name = names[0..-2].join('_')
            else
              io_name = row[1]
            end
          else
            io_name = row[1]
          end
        else
          io_name = row[1]
        end
      else
        import_log.count_failed
        import_log.log_error(["IO Name can't be blank"])
        next
      end

      io_start_date = nil
      if row[2].present?
        begin
          io_start_date = Date.strptime(row[2].strip, "%m/%d/%Y")
          if io_start_date.year < 100
            io_start_date = Date.strptime(row[2].strip, "%m/%d/%y")
          end
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['IO Start Date must be a valid datetime'])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(['IO Start Date must be present'])
        next
      end

      io_end_date = nil
      if row[3].present?
        begin
          io_end_date = Date.strptime(row[3].strip, "%m/%d/%Y")
          if io_end_date.year < 100
            io_end_date = Date.strptime(row[3].strip, "%m/%d/%y")
          end
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['IO End Date must be a valid datetime'])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(['IO End Date must be present'])
        next
      end

      if (io_end_date && io_start_date) && io_start_date > io_end_date
        import_log.count_failed
        import_log.log_error(['IO Start Date must preceed IO End Date'])
        next
      end

      io_budget = nil
      io_budget_loc = nil
      if row[4]
        io_budget = Float(row[4].strip) rescue false
        io_budget_loc = io_budget
        unless io_budget
          import_log.count_failed
          import_log.log_error(["IO Budget must be a numeric value"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["IO Budget can't be blank"])
        next
      end

      curr_cd = nil
      if row[5]
        curr_cd = row[5].strip
        if !(list_of_currencies.include?(curr_cd))
          import_log.count_failed
          import_log.log_error(["Currency #{curr_cd} is not found"])
          next
        elsif !(io_id.nil?) && io.curr_cd != curr_cd
          import_log.count_failed
          import_log.log_error(["IO currency #{io.curr_cd} does not match #{curr_cd}"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Currency code can't be blank"])
        next
      end

      advertiser = nil
      if row[6]
        advertiser = row[6].strip
      else
        import_log.count_failed
        import_log.log_error(["Advertiser can't be blank"])
        next
      end

      agency = nil
      if row[7]
        agency = row[7].strip
      end

      # =========================Display Line Item
      line_number = nil
      if row[8]
        line_number = Integer(row[8].strip) rescue false
        unless line_number
          import_log.count_failed
          import_log.log_error(["Line # must be a numeric value"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Line # can't be blank"])
        next
      end

      ad_server = row[9]

      start_date = nil
      if row[10].present?
        begin
          start_date = Date.strptime(row[10].strip, "%m/%d/%Y")
          if start_date.year < 100
            start_date = Date.strptime(row[10].strip, "%m/%d/%y")
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
      if row[11].present?
        begin
          end_date = Date.strptime(row[11].strip, "%m/%d/%Y")
          if end_date.year < 100
            end_date = Date.strptime(row[11].strip, "%m/%d/%y")
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

      if io.present?
        if start_date < io.start_date
          import_log.count_failed
          import_log.log_error(['start date can\'t be prior the IO start date'])
          next
        end
        if end_date > io.end_date
          import_log.count_failed
          import_log.log_error(['end date can\'t be after the IO end date'])
          next
        end
      end

      product_id = nil
      ad_server_product = nil

      i = 0
      if row[12]
        product_full_name = row[12].strip
        if current_user.company.product_options_enabled && current_user.company.product_option1_enabled
          i += 1
          product_full_name += ' ' + row[13].strip
        end
        if current_user.company.product_options_enabled && current_user.company.product_option2_enabled
          i += 1
          product_full_name += ' ' + row[14].strip
        end
        products = current_user
                       .company
                       .products
                       .joins(:ad_units)
                       .where('products.full_name ilike :product_full_name OR ad_units.name ilike :product_name', product_name: row[12].strip, product_full_name: product_full_name)
        if products.count > 0
          product_id = products.first.id
          ad_server_product = row[12].strip
        else
          import_log.count_failed
          import_log.log_error(["No matching product"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Product can't be blank"])
        next
      end

      qty = nil
      if row[13+i]
        qty = Integer(row[13+i].strip) rescue false
        unless qty
          import_log.count_failed
          import_log.log_error(["Qty must be a numeric value"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Qty can't be blank"])
        next
      end

      price = row[14+i]
      pricing_type = row[15+i]

      budget = nil
      budget_loc = nil
      if row[16+i]
        budget = Float(row[16+i].strip) rescue false
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

      budget_delivered = nil
      budget_delivered_loc = nil
      if row[17+i]
        budget_delivered = Float(row[17+i].strip) rescue false
        budget_delivered_loc = budget_delivered
        unless budget_delivered
          import_log.count_failed
          import_log.log_error(["Budget Delivered must be a numeric value"])
          next
        end
      end

      budget_remaining = nil
      budget_remaining_loc = nil
      if row[18+i]
        budget_remaining = Float(row[18+i].strip) rescue false
        budget_remaining_loc = budget_remaining
        unless budget_remaining
          import_log.count_failed
          import_log.log_error(["Budget Remaining must be a numeric value"])
          next
        end
      end

      qty_delivered = nil
      if row[19+i]
        qty_delivered = Float(row[19+i].strip) rescue false
        unless qty_delivered
          import_log.count_failed
          import_log.log_error(["Qty Delivered must be a numeric value"])
          next
        end
      end

      qty_remaining = nil
      if row[20+i]
        qty_remaining = Float(row[20+i].strip) rescue false
        unless qty_remaining
          import_log.count_failed
          import_log.log_error(["Qty Remaining must be a numeric value"])
          next
        end
      end

      qty_delivered_3p = nil
      if row[21+i]
        qty_delivered_3p = Float(row[21+i].strip) rescue false
        unless qty_delivered_3p
          import_log.count_failed
          import_log.log_error(["3P Qty Delivered must be a numeric value"])
          next
        end
      end

      qty_remaining_3p = nil
      if row[22+i]
        qty_remaining_3p = Float(row[22+i].strip) rescue false
        unless qty_remaining_3p
          import_log.count_failed
          import_log.log_error(["3P Qty Remaining must be a numeric value"])
          next
        end
      end

      budget_delivered_3p = nil
      budget_delivered_3p_loc = nil
      if row[23+i]
        budget_delivered_3p = Float(row[23+i].strip) rescue false
        budget_delivered_3p_loc = budget_delivered_3p
        unless budget_delivered_3p
          import_log.count_failed
          import_log.log_error(["3P Budget Delivered must be a numeric value"])
          next
        end
      end

      budget_remaining_3p = nil
      budget_remaining_3p_loc = nil
      if row[24+i]
        budget_remaining_3p = Float(row[24+i].strip) rescue false
        budget_remaining_3p_loc = budget_remaining_3p
        unless budget_remaining_3p
          import_log.count_failed
          import_log.log_error(["3P Budget Remaining must be a numeric value"])
          next
        end
      end

      temp_io_params = {
          name: io_name,
          start_date: io_start_date,
          end_date: io_end_date,
          budget: io_budget,
          budget_loc: io_budget_loc,
          curr_cd: curr_cd,
          advertiser: advertiser,
          agency: agency,
          external_io_number: external_io_number,
          company_id: current_user.company_id
      }

      display_line_item_params = {
          io_id: io_id,
          line_number: line_number,
          ad_server: ad_server,
          start_date: start_date,
          end_date: end_date,
          product_id: product_id,
          ad_server_product: ad_server_product,
          quantity: qty,
          price: price,
          pricing_type: pricing_type,
          budget: budget,
          budget_loc: budget_loc,
          budget_delivered: budget_delivered,
          budget_delivered_loc: budget_delivered_loc,
          budget_remaining: budget_remaining,
          budget_remaining_loc: budget_remaining_loc,
          quantity_delivered: qty_delivered,
          quantity_remaining: qty_remaining,
          quantity_delivered_3p: qty_delivered_3p,
          quantity_remaining_3p: qty_remaining_3p,
          budget_delivered_3p: budget_delivered_3p,
          budget_delivered_3p_loc: budget_delivered_3p_loc,
          budget_remaining_3p: budget_remaining_3p,
          budget_remaining_3p_loc: budget_remaining_3p_loc
      }

      if io_id.nil?
        if start_date < io_start_date
          import_log.count_failed
          import_log.log_error(['start date can\'t be prior the IO start date'])
          next
        end
        if end_date > io_end_date
          import_log.count_failed
          import_log.log_error(['end date can\'t be after the IO end date'])
          next
        end

        temp_io = TempIo.find_by_external_io_number(external_io_number)
        if temp_io.nil?
          temp_io = TempIo.create(temp_io_params)
        else
          # temp_io_params[:id] = temp_io.id
          temp_io.update_attributes(temp_io_params)
        end

        unless temp_io.exchange_rate
          import_log.count_failed
          import_log.log_error(["No exchange rate for #{temp_io.curr_cd} found at #{temp_io.created_at.strftime("%m/%d/%Y")}"])
          next
        end

        display_line_item_params[:temp_io_id] = temp_io.id
        display_line_item_params = self.convert_params_currency(temp_io.exchange_rate, display_line_item_params)
      else
        unless io.exchange_rate
          import_log.count_failed
          import_log.log_error(["No exchange rate for #{io.curr_cd} found at #{io.created_at.strftime("%m/%d/%Y")}"])
          next
        end

        display_line_item_params = self.convert_params_currency(io.exchange_rate, display_line_item_params)

        io_change[:time_period_ids] += current_user.company.time_period_ids(io.start_date, io.end_date)

        if io.content_fees.count == 0
          if io_start_date < io.start_date
            io.start_date = io_start_date
          end
          if io_end_date < io.end_date
            io.end_date = io_end_date
          end
        end

        io_change[:time_period_ids] += current_user.company.time_period_ids(io.start_date, io.end_date)
        io_change[:user_ids] += io.users.collect{|item| item.id}
        io_change[:product_ids] += io.products.collect{|item| item.id}
        io_change[:product_ids] += [product_id] if product_id.present?
        io.external_io_number = external_io_number
        io.save
        deal_change[:time_period_ids] += current_user.company.time_period_ids(io.deal.start_date, io.deal.end_date)
        deal_change[:stage_ids] += [io.deal.stage_id] if io.deal.stage_id.present?
        deal_change[:user_ids] += io.deal.deal_members.collect{|item| item.user_id}
        deal_change[:product_ids] += io.deal.deal_products.collect{|item| item.product_id}
      end
      display_line_item = nil
      if io_id.nil?
        display_line_items = DisplayLineItem.where("line_number=? and temp_io_id=?", line_number, temp_io.id)
      else
        display_line_items = DisplayLineItem.where("line_number=? and io_id=?", line_number, io_id)
      end

      if display_line_items.count > 0
        display_line_item = display_line_items.first
      end

      if display_line_item.present?
        import_log.count_imported
        display_line_item.update(display_line_item_params)
      else
        import_log.count_imported
        DisplayLineItem.create(display_line_item_params)
      end
    end

    Io.set_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItem.set_callback(:save, :after, :update_revenue_fact_callback)
    DisplayLineItemBudget.set_callback(:save, :after, :update_revenue_fact_callback)

    io_change[:time_period_ids] = io_change[:time_period_ids].uniq
    io_change[:user_ids] = io_change[:user_ids].uniq
    io_change[:product_ids] = io_change[:product_ids].uniq

    deal_change[:time_period_ids] = deal_change[:time_period_ids].uniq
    deal_change[:user_ids] = deal_change[:user_ids].uniq
    deal_change[:product_ids] = deal_change[:product_ids].uniq
    deal_change[:stage_ids] = deal_change[:stage_ids].uniq

    ForecastRevenueCalculatorWorker.perform_async(io_change)

    ForecastPipelineCalculatorWorker.perform_async(deal_change)

    import_log.save
  end

  def is_cpd_price_type?
    pricing_type == 'CPD'
  end

  def ave_run_rate
    return @ave_run_rate if defined?(@ave_run_rate)
    total_days = 0
    total_amount = 0
    self.display_line_item_budgets.each do |display_line_item_budget|
      days = [[self.end_date, display_line_item_budget.end_date].min - [display_line_item_budget.start_date, self.start_date].max + 1, 0].max
      total_days += days
      total_amount += display_line_item_budget.daily_budget * days
    end
    remaining_days = self.end_date - self.start_date + 1 - total_days
    @ave_run_rate = remaining_days > 0 ? [(self.budget - total_amount) / remaining_days, 0].max : 0
    @ave_run_rate.to_f
  end

  def merge_recursively(a, b)
    a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end
  def as_json(options = {})
    super(merge_recursively(options,
        include: {
          product: {
            methods: [
              :level0,
              :level1,
              :level2
            ]
          }
        }
      )
    )
  end

  private

  def self.convert_params_currency(exchange_rate, params)
    params[:budget] = params[:budget_loc] / exchange_rate
    params[:budget_delivered] = params[:budget_delivered_loc] / exchange_rate if params[:budget_delivered_loc]
    params[:budget_remaining] = params[:budget_remaining_loc] / exchange_rate if params[:budget_remaining_loc]
    params[:budget_delivered_3p] = params[:budget_delivered_3p_loc] / exchange_rate if params[:budget_delivered_3p_loc]
    params[:budget_remaining_3p] = params[:budget_remaining_3p_loc] / exchange_rate if params[:budget_remaining_3p_loc]

    params
  end
end
