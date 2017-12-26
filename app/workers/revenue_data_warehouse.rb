class RevenueDataWarehouse < BaseWorker
  def perform
    generate_account_revenue_facts
  end

  def generate_account_revenue_facts
    time_dimensions = TimeDimension.all
    all_ios = Io.all.includes(:content_fees, :content_fee_product_budgets, :display_line_items, :display_line_item_budgets)

    Client.all.each do |client|
      client_revenues = []

      ios = all_ios.select do |io|
        io.agency_id == client.id ||
        io.advertiser_id == client.id
      end

      ios.each do |io|
        io_time_dimensions = time_dimensions.select do |io_time_dimension|
          io_time_dimension.start_date <= io.end_date &&
          io_time_dimension.end_date >= io.start_date
        end
        io_time_dimensions.each do |io_time_dimension|
          time_period_revenue = total_effective_revenue_budget(io, io_time_dimension.start_date, io_time_dimension.end_date)
          client_revenue = client_revenues.find { |rev| rev[:time_dimension_id] == io_time_dimension.id }
          if client_revenue
            client_revenue[:revenue_amount] += time_period_revenue
          else
            client_revenues << {
              revenue_amount: time_period_revenue,
              time_dimension_id: io_time_dimension.id
            }
          end
        end
      end

      client_revenues.each do |client_revenue|
        revenue_fact = AccountRevenueFact.find_or_initialize_by(
          company_id: client.company_id,
          account_dimension_id: client.id,
          time_dimension_id: client_revenue[:time_dimension_id]
        )

        revenue_fact.update(
          category_id: client.client_category_id,
          subcategory_id: client.client_subcategory_id,
          revenue_amount: client_revenue[:revenue_amount]
        )
      end
    end
  end

  def total_effective_revenue_budget(io, start_date, end_date)
    total_budget = 0
    io.content_fees.each do |content_fee|
      content_fee_product_budgets = content_fee.content_fee_product_budgets.select do |product_budget|
        product_budget.start_date <= end_date &&
        product_budget.end_date >= start_date
      end

      content_fee_product_budgets.each do |content_fee_product_budget|
        total_budget += content_fee_product_budget.corrected_daily_budget(io.start_date, io.end_date) * effective_days(start_date, end_date, [content_fee_product_budget, io])
      end
    end

    io.display_line_items.each do |display_line_item|
      in_budget_days = 0
      in_budget_total = 0
      display_line_item.display_line_item_budgets.each do |display_line_item_budget|
        in_days = effective_days(start_date, end_date, [display_line_item, display_line_item_budget])
        in_budget_days += in_days
        in_budget_total += display_line_item_budget.daily_budget * in_days
      end
      total_budget += in_budget_total + display_line_item.ave_run_rate * (effective_days(start_date, end_date, [display_line_item, io]) - in_budget_days)
    end
    total_budget
  end

  def effective_days(start_date, end_date, objects)
    from = [start_date]
    to = [end_date]
    from += objects.collect{ |object| object.start_date }
    to += objects.collect{ |object| object.end_date }

    [(to.min.to_date - from.max.to_date) + 1, 0].max.to_f
  end
end
