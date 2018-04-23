namespace :generate_missing_ios do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    exit unless args[:company_id]

    company = Company.find(args[:company_id])
    exit unless company

    deals = company.deals.at_percent(100).joins("LEFT JOIN ios ON deals.id = ios.io_number").where("ios.id IS NULL")
    deals.each { |deal| deal.generate_io }
  end
end
