class DisplayLineItem < ActiveRecord::Base
  belongs_to :io
  belongs_to :product
  belongs_to :temp_io

  has_many :display_line_item_budgets

  has_one :request, as: :requestable

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

  before_create :set_alert
  before_update :set_alert

  after_create :update_io_budget
  after_update :update_io_budget

  scope :for_time_period, -> (start_date, end_date) { where('display_line_items.start_date <= ? AND display_line_items.end_date >= ?', end_date, start_date) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) }
  
  def update_io_budget
    if io.present?
      io.update_total_budget
      if io.deal.present?
        io.deal.close_display_product()
      end
    end

    if io_id_changed? && io.present?
      io.users.update_all(pos_balance_cnt: 0, neg_balance_cnt: 0, pos_balance: 0, neg_balance: 0, pos_balance_l_cnt: 0, neg_balance_l_cnt: 0, pos_balance_l: 0, neg_balance_l: 0, last_alert_at: DateTime.now)
      io.users.each do |user|
        user.set_alert(true)
      end
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

  def self.import(file, current_user)
    errors = []
    row_number = 0
    list_of_currencies = Currency.pluck(:curr_cd)

    CSV.parse(file, headers: true) do |row|
      row_number += 1
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
        error = { row: row_number, message: ["Ext IO Num can't be blank"] }
        errors << error
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
        error = { row: row_number, message: ["IO Name can't be blank"] }
        errors << error
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
          error = {row: row_number, message: ['IO Start Date must be a valid datetime'] }
          errors << error
          next
        end
      else
        error = {row: row_number, message: ['IO Start Date must be present'] }
        errors << error
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
          error = {row: row_number, message: ['IO End Date must be a valid datetime'] }
          errors << error
          next
        end
      else
        error = {row: row_number, message: ['IO End Date must be present'] }
        errors << error
        next
      end

      if (io_end_date && io_start_date) && io_start_date > io_end_date
        error = {row: row_number, message: ['IO Start Date must preceed IO End Date'] }
        errors << error
        next
      end

      io_budget = nil
      io_budget_loc = nil
      if row[4]
        io_budget = Float(row[4].strip) rescue false
        io_budget_loc = io_budget
        unless io_budget
          error = { row: row_number, message: ["IO Budget must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["IO Budget can't be blank"] }
        errors << error
        next
      end

      curr_cd = nil
      if row[5]
        curr_cd = row[5].strip
        if !(list_of_currencies.include?(curr_cd))
          error = { row: row_number, message: ["Currency #{curr_cd} is not found"] }
          errors << error
          next
        elsif !(io_id.nil?) && io.curr_cd != curr_cd
          error = { row: row_number, message: ["IO currency #{io.curr_cd} does not match #{curr_cd}"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Currency code can't be blank"] }
        errors << error
        next
      end

      advertiser = nil
      if row[6]
        advertiser = row[6].strip
      else
        error = { row: row_number, message: ["Advertiser can't be blank"] }
        errors << error
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
          error = { row: row_number, message: ["Line # must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Line # can't be blank"] }
        errors << error
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
          error = {row: row_number, message: ['Start Date must be a valid datetime'] }
          errors << error
          next
        end
      else
        error = {row: row_number, message: ['Start Date must be present'] }
        errors << error
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
          error = {row: row_number, message: ['End Date must be a valid datetime'] }
          errors << error
          next
        end
      else
        error = {row: row_number, message: ['End Date must be present'] }
        errors << error
        next
      end

      if (end_date && start_date) && start_date > end_date
        error = {row: row_number, message: ['Start Date must preceed End Date'] }
        errors << error
        next
      end

      product_id = nil
      ad_server_product = nil

      if row[12]
        products = current_user.company.products.where("name ilike ?", row[12].strip)
        if products.count > 0
          product_id = products.first.id
        else
          ad_server_product = row[12].strip
          products = current_user.company.products.where(revenue_type: 'Display')
          if products.count > 0
            product_id = products.first.id
          end
        end
      else
        error = { row: row_number, message: ["Product can't be blank"] }
        errors << error
        next
      end

      qty = nil
      if row[13]
        qty = Integer(row[13].strip) rescue false
        unless qty
          error = { row: row_number, message: ["Qty must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Qty can't be blank"] }
        errors << error
        next
      end

      price = row[14]
      pricing_type = row[15]

      budget = nil
      budget_loc = nil
      if row[16]
        budget = Float(row[16].strip) rescue false
        budget_loc = budget
        unless budget
          error = { row: row_number, message: ["Budget must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Budget can't be blank"] }
        errors << error
        next
      end

      budget_delivered = nil
      budget_delivered_loc = nil
      if row[17]
        budget_delivered = Float(row[17].strip) rescue false
        budget_delivered_loc = budget_delivered
        unless budget_delivered
          error = { row: row_number, message: ["Budget Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_remaining = nil
      budget_remaining_loc = nil
      if row[18]
        budget_remaining = Float(row[18].strip) rescue false
        budget_remaining_loc = budget_remaining
        unless budget_remaining
          error = { row: row_number, message: ["Budget Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_delivered = nil
      if row[19]
        qty_delivered = Float(row[19].strip) rescue false
        unless qty_delivered
          error = { row: row_number, message: ["Qty Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_remaining = nil
      if row[20]
        qty_remaining = Float(row[20].strip) rescue false
        unless qty_remaining
          error = { row: row_number, message: ["Qty Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_delivered_3p = nil
      if row[21]
        qty_delivered_3p = Float(row[21].strip) rescue false
        unless qty_delivered_3p
          error = { row: row_number, message: ["3P Qty Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_remaining_3p = nil
      if row[22]
        qty_remaining_3p = Float(row[22].strip) rescue false
        unless qty_remaining_3p
          error = { row: row_number, message: ["3P Qty Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_delivered_3p = nil
      budget_delivered_3p_loc = nil
      if row[23]
        budget_delivered_3p = Float(row[23].strip) rescue false
        budget_delivered_3p_loc = budget_delivered_3p
        unless budget_delivered_3p
          error = { row: row_number, message: ["3P Budget Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_remaining_3p = nil
      budget_remaining_3p_loc = nil
      if row[24]
        budget_remaining_3p = Float(row[24].strip) rescue false
        budget_remaining_3p_loc = budget_remaining_3p
        unless budget_remaining_3p
          error = { row: row_number, message: ["3P Budget Remaining must be a numeric value"] }
          errors << error
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
        temp_io = TempIo.find_by_external_io_number(external_io_number)
        if temp_io.nil?
          temp_io = TempIo.create(temp_io_params)
        else
          # temp_io_params[:id] = temp_io.id
          temp_io.update_attributes(temp_io_params)
        end

        unless temp_io.exchange_rate
          error = { row: row_number, message: ["No exchange rate for #{temp_io.curr_cd} found at #{temp_io.created_at.strftime("%m/%d/%Y")}"] }
          errors << error
          next
        end

        display_line_item_params[:temp_io_id] = temp_io.id
        display_line_item_params = self.convert_params_currency(temp_io.exchange_rate, display_line_item_params)
      else
        unless io.exchange_rate
          error = { row: row_number, message: ["No exchange rate for #{io.curr_cd} found at #{io.created_at.strftime("%m/%d/%Y")}"] }
          errors << error
          next
        end

        display_line_item_params = self.convert_params_currency(io.exchange_rate, display_line_item_params)

        if io.content_fees.count == 0
          if io_start_date < io.start_date
            io.start_date = io_start_date
          end
          if io_end_date < io.end_date
            io.end_date = io_end_date
          end
        end
        io.external_io_number = external_io_number
        io.save
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
        display_line_item.update(display_line_item_params)
      else
        DisplayLineItem.create(display_line_item_params)
      end
    end

    errors
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
          product: {}
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
