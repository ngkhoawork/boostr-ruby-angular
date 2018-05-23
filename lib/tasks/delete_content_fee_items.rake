namespace :delete_content_fee_items do
  desc "Delete content fee items"
  task :process_task, [:company_id, :product_id] => [:environment] do |t, args|
    if args[:company_id].present? && args[:product_id].present?
      company = Company.find(args[:company_id])
      company.ios.each do |io|
        io.content_fees.for_product_id(args[:product_id] == 'all' ? nil : args[:product_id]).destroy_all
      end
    end
  end
end
