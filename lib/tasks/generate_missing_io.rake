namespace :generate_missing_ios do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    if args[:company_id]
      company = Company.find(args[:company_id])
      if company.present?
        deals = company.deals.at_percent(100).joins("LEFT JOIN ios ON deals.id = ios.io_number").where("ios.id IS NULL")
        deals.each { |deal| deal.generate_io }
      end
    end
  end

end
