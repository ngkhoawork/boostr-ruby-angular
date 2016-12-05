class DisplayLineItemBudget < ActiveRecord::Base
  belongs_to :display_line_item

  def daily_budget
    budget.to_f / (end_date - start_date + 1).to_i
  end

  def self.import(file, current_user)
    errors = []
    row_number = 0

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
        else
          error = { row: row_number, message: ["Ext IO Num doesn't match with any IO."] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Ext IO Num can't be blank"] }
        errors << error
        next
      end

      display_line_item = nil
      if row[1]
        display_line_item_num = row[1].strip
        display_line_items = io.display_line_items.where(line_number: display_line_item_num)
        if display_line_items.count > 0
          display_line_item = display_line_items[0]
        else
          error = { row: row_number, message: ["Display Line Number doesn't match with any display line items."] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Display Line Number can't be blank"] }
        errors << error
        next
      end

      budget = nil
      if row[2]
        budget = Float(row[2].strip) rescue false
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

      start_date = nil
      if row[3].present?
        begin
          start_date = Date.strptime(row[3].strip, "%m/%d/%Y")
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
      if row[4].present?
        begin
          end_date = Date.strptime(row[4].strip, "%m/%d/%Y")
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

      display_line_item_budget_params = {
          external_io_number: external_io_number,
          budget: budget,
          start_date: start_date,
          end_date: end_date
      }

      display_line_item_budgets = display_line_item.display_line_item_budgets.where("date_part('year', start_date) = ? and date_part('month', start_date) = ?", start_date.year, start_date.month)
      if display_line_item_budgets.count > 0
        display_line_item_budget = display_line_item_budgets[0]
        display_line_item_budget.update_attributes(display_line_item_budget_params)
      else
        display_line_item.display_line_item_budgets.create(display_line_item_budget_params)
      end
    end

    errors
  end
end
