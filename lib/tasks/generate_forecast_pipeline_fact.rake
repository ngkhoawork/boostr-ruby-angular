require 'forecast_pipeline_fact_calculator'
namespace :generate_forecast_pipeline_facts do
  include ForecastPipelineFactCalculator
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    if args[:company_id]
      Company.all.each do |company|
        company.time_periods.each do |time_period|
          company.users.each do |user|
            company.products.each do |product|
              company.stages.each do |stage|
                forecast_pipeline_fact_calculator = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
                forecast_pipeline_fact_calculator.calculate()
              end
            end
          end
        end
      end
    end
  end

end
