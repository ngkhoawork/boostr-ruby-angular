namespace :delete_io_cost_monthly_amounts do
  desc "Delete io cost monthly amounts which are created at specific date(MM/DD/YYYY)"
  task :process_task, [:company_id, :created_at] => [:environment] do |t, args|
    if args[:company_id].present? && args[:created_at].present?
      company = Company.find(args[:company_id])
      created_at = Date.strptime(args[:created_at].gsub(/[-:]/, '/'), '%m/%d/%Y')
      company.costs
             .where("DATE_PART('year', costs.created_at) = ? AND DATE_PART('month', costs.created_at) = ? AND DATE_PART('day', costs.created_at) = ?", 
                    created_at.year, 
                    created_at.month,
                    created_at.day)
             .destroy_all
      company.cost_monthly_amounts
             .where("DATE_PART('year', cost_monthly_amounts.created_at) = ? AND DATE_PART('month', cost_monthly_amounts.created_at) = ? AND DATE_PART('day', cost_monthly_amounts.created_at) = ?", 
                    created_at.year, 
                    created_at.month,
                    created_at.day)
             .destroy_all
      company.costs
             .where("DATE_PART('year', costs.updated_at) = ? AND DATE_PART('month', costs.updated_at) = ? AND DATE_PART('day', costs.updated_at) = ?", 
                    created_at.year, 
                    created_at.month,
                    created_at.day)
             .each do |cost|
        cost.update_budget
      end
    end
  end
end
