module ForecastCostFactCalculator
  class Calculator
    def initialize(time_period, user, product)
      @time_period = time_period
      @forecast_time_dimension = ForecastTimeDimension.find_by_id(time_period.id)
      @start_date = time_period.start_date
      @end_date = time_period.end_date
      @user = user
      @product = product
    end

    def calculate
      total = 0
      monthly_value = {}

      return if !@forecast_time_dimension

      months.each do |month_row|
        monthly_value[month_row[:start_date].strftime("%b-%y")] = 0
      end
      ios.each do |io|
        io_member = io.io_members.find_by(user_id: @user.id)
        share = io_member.share
        costs = io.costs
        costs = costs.for_product_ids([@product.id]) if @product.present?
        costs.each do |cost_item|
          cost_item.cost_monthly_amounts.for_time_period(@start_date, @end_date).each do |cost_monthly_amount_item|
            calc_amt = cost_monthly_amount_item.corrected_daily_budget(io.start_date, io.end_date) * effective_days(io_member, [cost_monthly_amount_item]) * (share/100.0)
            monthly_value[cost_monthly_amount_item.start_date.strftime("%b-%y")] += calc_amt
            total += calc_amt
          end
        end
      end

      forecast_cost_fact = ForecastCostFact.find_or_initialize_by(
        forecast_time_dimension_id: @forecast_time_dimension.id,
        user_dimension_id: @user.id,
        product_dimension_id: @product.id
      )
      if forecast_cost_fact.id.present? && total <= 0
        puts "==========="
        forecast_cost_fact.destroy
      end
      if (total > 0)
        forecast_cost_fact.amount = total
        forecast_cost_fact.monthly_amount = monthly_value
        forecast_cost_fact.save
      end

      monthly_value
    end

    def open_deals
      @open_deals ||= @user.deals.where(open: true).for_time_period(@start_date, @end_date).by_stage_id(@stage.id).includes(:deal_product_budgets).to_a
    end

    def ios
      @ios ||= @user.ios.for_time_period(@start_date, @end_date).to_a
    end

    def months
      return @months if defined?(@months)

      @months = (@start_date.to_date..@end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
      @months
    end


    def effective_days(effecter, objects)
      from = [@start_date]
      to = [@end_date]
      from += objects.collect{ |object| object.start_date }
      to += objects.collect{ |object| object.end_date }

      if effecter.present? && effecter.from_date && effecter.to_date
        from << effecter.from_date
        to << effecter.to_date
      end
      [(to.min.to_date - from.max.to_date) + 1, 0].max.to_f
    end
  end
end
