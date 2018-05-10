desc "update display line item's delivered and remaining budget according to the sum of monthly budgets"

task :reset_display_line_item_delivered_budget, [:company_id] => [:environment] do |_, args|
  company = args[:company_id] && Company.find_by_id(args[:company_id])
  exit unless company

  company.display_line_items.find_in_batches(batch_size: 20) do |group|
    group.each do |item|
      budget_delivered = item.display_line_item_budgets.sum(:budget)
      budget_delivered_loc = item.display_line_item_budgets.sum(:budget_loc)
      budget_remaining = [(item.budget || 0) - budget_delivered, 0].max
      budget_remaining_loc = [(item.budget_loc || 0) - budget_delivered_loc, 0].max
      
      puts "============"
      puts "Item id: #{item.id}"
      puts "Old delivered: #{item.budget_delivered}"
      puts "New delivered: #{budget_delivered}"

      item.update(
        budget_delivered: budget_delivered,
        budget_delivered_loc: budget_delivered_loc,
        budget_remaining: budget_remaining,
        budget_remaining_loc: budget_remaining_loc
      )
    end
  end
end
