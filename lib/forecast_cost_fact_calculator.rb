module ForecastCostFactCalculator
  class Calculator
    def initialize(time_period, user, product)
      @time_period = time_period
      @forecast_time_dimension = ForecastTimeDimension.find_by_id(time_period.id)
      @start_date = time_period.start_date
      @end_date = time_period.end_date
      @user = user
      @product = product
      @monthly_value = init_monthly_value
    end

    def calculate
      return if !@forecast_time_dimension
      
      total = calculate_forecast_amount

      forecast_cost_fact = ForecastCostFact.find_or_initialize_by(
        forecast_time_dimension_id: @forecast_time_dimension.id,
        user_dimension_id: @user.id,
        product_dimension_id: @product.id
      )
      if forecast_cost_fact.id.present? && total <= 0
        forecast_cost_fact.destroy
      end
      if (total > 0)
        forecast_cost_fact.amount = total
        forecast_cost_fact.monthly_amount = @monthly_value
        forecast_cost_fact.save
      end
    end

    def calculate_forecast_amount
      ios.inject(0) do |total, io|
        total += io_total(io)
      end
    end

    def io_total(io)
      io_member = io.io_members.find_by(user_id: @user.id)
      costs = io.costs
      costs = costs.for_product_ids([@product.id]) if @product.present?
      costs.inject(0) do |total, cost|
        total += cost_total(cost, io, io_member)
      end
    end

    def cost_total(cost, io, io_member)
      cost_amounts = cost.cost_monthly_amounts.for_time_period(@start_date, @end_date)
      cost_amounts.inject(0) do |total, cost_amount|
        total += cost_monthly_amount_total(cost_amount, io, io_member)
      end
    end

    def cost_monthly_amount_total(cost_amount, io, io_member)
      daily_budget = cost_amount.corrected_daily_budget(io.start_date, io.end_date)
      days = effective_days(io_member, [cost_amount])

      amount = daily_budget * days * io_member.share / 100.0

      month_name = cost_amount.start_date.strftime("%b-%y")
      @monthly_value[month_name] += calc_amt

      amount
    end

    def init_monthly_value
      months.inject({}) do |result, month_row|
        month_name = month_row[:start_date].strftime("%b-%y")
        result[month_name] = 0
        result
      end
    end

    def open_deals
      @open_deals ||= @user.deals
        .open_partial
        .for_time_period(@start_date, @end_date)
        .by_stage_id(@stage.id)
        .includes(:deal_product_budgets)
        .to_a
    end

    def ios
      @ios ||= @user.ios.for_time_period(@start_date, @end_date).to_a
    end

    def months
      return @months if defined?(@months)

      @months = (@start_date.to_date..@end_date.to_date)
        .map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } 
        }.uniq
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
