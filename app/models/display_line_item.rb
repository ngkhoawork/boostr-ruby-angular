class DisplayLineItem < ActiveRecord::Base
  belongs_to :io
  belongs_to :product
  belongs_to :temp_io

  before_create :set_alert
  before_update :set_alert

  after_create :update_io_budget
  after_update :update_io_budget

  def update_io_budget
    if io.present?
      io.update_total_budget
    end

    if io_id_changed? && io.present?
      io.members.update_all(pos_balance_cnt: 0, neg_balance_cnt: 0, pos_balance: 0, neg_balance: 0, pos_balance_l_cnt: 0, neg_balance_l_cnt: 0, pos_balance_l: 0, neg_balance_l: 0, last_alert_at: DateTime.now)
      io.members.each do |user|
        user.set_alert(true)
      end
    end
  end

  def set_alert(should_save=false)
    if !budget.nil? && !budget_remaining.nil?
      if budget > 0 && start_date < DateTime.now && DateTime.now < end_date
        self.daily_run_rate = ((budget - budget_remaining)/(DateTime.now.to_date-start_date.to_date+1))
        if self.daily_run_rate != 0
          self.num_days_til_out_of_budget = budget_remaining/(self.daily_run_rate)
          self.balance = ((end_date.to_date-DateTime.now.to_date+1)-self.num_days_til_out_of_budget)*(self.daily_run_rate)
        else
          self.num_days_til_out_of_budget = 0
          self.balance = 0
        end
      else
        self.daily_run_rate = 0
        self.num_days_til_out_of_budget = 0
        self.balance = 0
      end
      self.last_alert_at = DateTime.now
    end
    self.save if should_save
  end

  def self.import(file, current_user)
    errors = []
    row_number = 0

    CSV.parse(file, headers: true) do |row|
      row_number += 1
      io_id = nil

      external_io_number = nil
      if row[0]
        external_io_number = row[0].strip
        ios = current_user.company.ios.where("external_io_number = ?", row[0].strip)
        if ios.count > 0
          io_id = ios[0].id
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

      start_date = nil
      if row[2].present?
        begin
          start_date = Date.parse(row[2])
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
      if row[3].present?
        begin
          end_date = Date.parse(row[3])
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

      io_budget = nil
      if row[4]
        io_budget = Float(row[4].strip) rescue false
        unless io_budget
          error = { row: row_number, message: ["IO Budget must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["IOBudget can't be blank"] }
        errors << error
        next
      end

      advertiser = nil
      if row[5]
        advertiser = row[5].strip
      else
        error = { row: row_number, message: ["Advertiser can't be blank"] }
        errors << error
        next
      end

      agency = nil
      if row[6]
        agency = row[6].strip
      else
        error = { row: row_number, message: ["Agency can't be blank"] }
        errors << error
        next
      end

      # =========================Display Line Item
      line_number = nil
      if row[7]
        line_number = Integer(row[7].strip) rescue false
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

      ad_server = row[8]

      product_id = nil

      if row[9]
        products = current_user.company.products.where("name ilike ?", row[9].strip)
        if products.count > 0
          product_id = products.first.id
        else
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
      if row[10]
        qty = Integer(row[10].strip) rescue false
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

      price = row[11]
      pricing_type = row[12]

      budget = nil
      if row[13]
        budget = Float(row[13].strip) rescue false
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
      if row[14]
        budget_delivered = Float(row[14].strip) rescue false
        unless budget_delivered
          error = { row: row_number, message: ["Budget Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_remaining = nil
      if row[15]
        budget_remaining = Float(row[15].strip) rescue false
        unless budget_remaining
          error = { row: row_number, message: ["Budget Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_delivered = nil
      if row[16]
        qty_delivered = Float(row[16].strip) rescue false
        unless qty_delivered
          error = { row: row_number, message: ["Qty Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_remaining = nil
      if row[17]
        qty_remaining = Float(row[17].strip) rescue false
        unless qty_remaining
          error = { row: row_number, message: ["Qty Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_delivered_3p = nil
      if row[18]
        qty_delivered_3p = Float(row[18].strip) rescue false
        unless qty_delivered_3p
          error = { row: row_number, message: ["3P Qty Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      qty_remaining_3p = nil
      if row[19]
        qty_remaining_3p = Float(row[19].strip) rescue false
        unless qty_remaining_3p
          error = { row: row_number, message: ["3P Qty Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_delivered_3p = nil
      if row[20]
        budget_delivered_3p = Float(row[20].strip) rescue false
        unless budget_delivered_3p
          error = { row: row_number, message: ["3P Budget Delivered must be a numeric value"] }
          errors << error
          next
        end
      end

      budget_remaining_3p = nil
      if row[21]
        budget_remaining_3p = Float(row[21].strip) rescue false
        unless budget_remaining_3p
          error = { row: row_number, message: ["3P Budget Remaining must be a numeric value"] }
          errors << error
          next
        end
      end

      temp_io_params = {
          name: io_name,
          start_date: start_date,
          end_date: end_date,
          budget: io_budget,
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
          quantity: qty,
          price: price,
          pricing_type: pricing_type,
          budget_delivered: budget_delivered,
          budget_remaining: budget_remaining,
          quantity_delivered: qty_delivered,
          quantity_remaining: qty_remaining,
          quantity_delivered_3p: qty_delivered_3p,
          quantity_delivered_3p: qty_remaining_3p,
          budget_delivered_3p: budget_delivered_3p,
          budget_remaining_3p: budget_remaining_3p
      }

      if io_id.nil?
        temp_io = TempIo.find_by_external_io_number(external_io_number)
        if temp_io.nil?
          temp_io = TempIo.create(temp_io_params)
        end

        display_line_item_params[:temp_io_id] = temp_io.id
      end
      display_line_item = DisplayLineItem.find_by_line_number(line_number)
      if display_line_item
        display_line_item.update(display_line_item_params)
      else
        DisplayLineItem.create(display_line_item_params)
      end
    end

    errors
  end

  def ave_run_rate
    return @ave_run_rate if defined?(@ave_run_rate)
    @ave_run_rate = self.budget / (self.end_date - self.start_date + 1)
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

end
