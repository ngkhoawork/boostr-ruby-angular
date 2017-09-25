namespace :import_datafeed do
  desc "Import Operative Cumulative Datafeed Archive"
  task :process_task, [:company_id] => [:environment] do |t, args|
    if args[:company_id]
      odc = OperativeDatafeedConfiguration.find_by(company_id: args[:company_id], switched_on: true)
      if odc.present?
        Operative::DatafeedService.new(odc, Date.today - 1.day).perform
      end
    end
  end
end
