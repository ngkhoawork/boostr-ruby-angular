module ForecastRevenueFactCalculator
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
        content_fees = io.content_fees
        content_fees = content_fees.for_product_id(@product.id) if @product.present?
        content_fees.each do |content_fee_item|
          content_fee_item.content_fee_product_budgets.for_time_period(@start_date, @end_date).each do |content_fee_product_budget_item|
            calc_amt = content_fee_product_budget_item.corrected_daily_budget(io.start_date, io.end_date) * effective_days(io_member, [content_fee_product_budget_item]) * (share/100.0)
            monthly_value[content_fee_product_budget_item.start_date.strftime("%b-%y")] += calc_amt
            total += calc_amt
          end
        end
        display_line_items = io.display_line_items
        display_line_items = display_line_items.for_product_id(@product.id) if @product.present?
        display_line_items.each do |display_line_item|
          ave_run_rate = display_line_item.ave_run_rate
          months.each do |month_row|
            from = [@start_date, display_line_item.start_date, io_member.from_date, month_row[:start_date]].max
            to = [@end_date, display_line_item.end_date, io_member.to_date, month_row[:end_date]].min
            no_of_days = [(to.to_date - from.to_date) + 1, 0].max
            in_budget_days = 0
            in_budget_total = 0
            display_line_item.display_line_item_budgets.each do |display_line_item_budget|
              in_from = [
                @start_date,
                display_line_item.start_date,
                io_member.from_date,
                display_line_item_budget.start_date,
                month_row[:start_date]
              ].max

              in_to = [
                @end_date,
                display_line_item.end_date,
                io_member.to_date,
                display_line_item_budget.end_date,
                month_row[:end_date]
              ].min

              in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
              in_budget_days += in_days
              in_budget_total += display_line_item_budget.daily_budget * in_days * (share/100.0)
            end

            calc_amt = in_budget_total + ave_run_rate * (no_of_days - in_budget_days) * (share/100.0)
            monthly_value[month_row[:start_date].strftime("%b-%y")] += calc_amt
            total += calc_amt
          end
        end
      end

      create_forecast_revenue_fact(total, monthly_value)

      monthly_value
    end

    def create_forecast_revenue_fact(total, monthly_value)
      if total > 0
        forecast_revenue_fact.update(
          amount: total,
          monthly_amount: monthly_value
        )
      elsif forecast_revenue_fact.id.present?
        forecast_revenue_fact.destroy
      end
    end

    def forecast_revenue_fact
      ForecastRevenueFact.find_or_initialize_by(
        forecast_time_dimension_id: @forecast_time_dimension.id,
        user_dimension_id: @user.id,
        product_dimension_id: @product.id
      )
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
