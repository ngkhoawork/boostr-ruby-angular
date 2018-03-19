module ForecastPipelineFactCalculator
  class Calculator
    def initialize(time_period, user, product, stage)
      @time_period = time_period
      @forecast_time_dimension = ForecastTimeDimension.find_by_id(time_period.id)
      @start_date = time_period.start_date
      @end_date = time_period.end_date
      @user = user
      @product = product
      @stage = stage
    end

    def calculate
      total = 0
      monthly_value = {}

      return if !@forecast_time_dimension

      deal_shares = {}
      @user.deal_members.each do |mem|
        deal_shares[mem.deal_id] = mem.share
      end

      open_deals.each do |deal|
        months.each do |month_row|
          monthly_value[month_row[:start_date].strftime("%b-%y")] ||= 0
        end
        deal_products = deal.deal_products.open
        deal_products = deal_products.for_product_id(@product.id) if @product.present?
        deal_products.each do |deal_product|
          deal_product.deal_product_budgets.for_time_period(@start_date, @end_date).each do |deal_product_budget|
            month_index = deal_product_budget.start_date.strftime("%b-%y")
            partial_budget = deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
            monthly_value[month_index] += partial_budget
            total += partial_budget
          end
        end
      end

      create_forecast_pipeline_fact(total, monthly_value)
    end

    def create_forecast_pipeline_fact(total, monthly_value)
      forecast_pipeline_fact = ForecastPipelineFact.find_or_initialize_by(
        forecast_time_dimension_id: @forecast_time_dimension.id,
        user_dimension_id: @user.id,
        product_dimension_id: @product.id,
        stage_dimension_id: @stage.id
      )
      if forecast_pipeline_fact.id.present? && total <= 0
        forecast_pipeline_fact.destroy
      end
      if (total > 0)
        forecast_pipeline_fact.amount = total
        forecast_pipeline_fact.monthly_amount = monthly_value
        forecast_pipeline_fact.probability = @stage.probability
        forecast_pipeline_fact.save
      end
    end

    def open_deals
      @open_deals ||= @user.deals.where(open: true).for_time_period(@start_date, @end_date).by_stage_id(@stage.id).includes(:deal_product_budgets).to_a
    end

    def months
      return @months if defined?(@months)

      @months = (@start_date.to_date..@end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
      @months
    end

    def number_of_days(comparer)
      from = [@start_date, comparer.start_date].max
      to = [@end_date, comparer.end_date].min
      [(to.to_date - from.to_date) + 1, 0].max
    end
  end
end
