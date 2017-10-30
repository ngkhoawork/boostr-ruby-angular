namespace :delete_display_line_items do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    if args[:company_id]
      company = Company.find(args[:company_id])
      if company.present?
        company.ios.each do |io|
          io.display_line_items.destroy_all
        end
      end
    end
  end

end
