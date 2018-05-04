namespace :reset_display_line_item_delivered_budget do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    exit unless args[:company_id]

    company = Company.find(args[:company_id])
    exit unless company

    company.display_line_items.each do |item|
      budget_delivered = item.display_line_item_budgets.sum(:budget)
      budget_delivered_loc = item.display_line_item_budgets.sum(:budget_loc)
      budget_remaining = [(item.budget || 0) - budget_delivered, 0].max
      budget_remaining_loc = [(item.budget_loc || 0) - budget_delivered_loc, 0].max
      
      puts "============"
      puts item.id
      puts item.budget_delivered
      puts budget_delivered

      item.update(
        budget_delivered: budget_delivered,
        budget_delivered_loc: budget_delivered_loc,
        budget_remaining: budget_remaining,
        budget_remaining_loc: budget_remaining_loc
      )
    end
  end
end
