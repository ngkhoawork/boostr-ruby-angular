desc "update display line item's delivered and remaining budget according to the sum of monthly budgets"

task :reset_display_line_item_delivered_budget, [:company_id] => [:environment] do |_, args|
  company = args[:company_id] && Company.find_by_id(args[:company_id])
  exit unless company

  company.display_line_items.find_in_batches do |group|
    group.each do |item|
      puts "Item id: #{item.id}"
      DisplayLineItem::UpdateBudgetDelivered.new(item).perform
    end
  end
end
