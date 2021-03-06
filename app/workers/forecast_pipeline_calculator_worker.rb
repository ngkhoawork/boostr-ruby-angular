class ForecastPipelineCalculatorWorker < BaseWorker
  def perform(deal_change, company_id = nil)
    manage_pipeline_facts(
      deal_change['time_period_ids'],
      deal_change['user_ids'],
      deal_change['product_ids'],
      deal_change['stage_ids']
    )
    if company_id.present?
      current_job = ForecastCalculationLog.find_by(company_id: company_id, finished: false)
      current_job.update(end_date: DateTime.now, finished: true)
    end
  end

  private

  def manage_pipeline_facts(time_period_ids, user_ids, product_ids, stage_ids)
    time_periods = TimePeriod.where(id: time_period_ids)
    users = User.where(id: user_ids)
    products = Product.where(id: product_ids)
    stages = Stage.where(id: stage_ids)
    time_periods.each do |time_period|
      users.each do |user|
        products.each do |product|
          stages.each do |stage|
            forecast_pipeline_fact_calculator = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
            forecast_pipeline_fact_calculator.calculate()
          end
        end
      end
    end
  end

end