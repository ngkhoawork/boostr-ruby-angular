class RevenueDataWarehouse < BaseWorker
  def perform
    truncate_account_revenue_facts
    generate_account_revenue_facts
  end

  private

  def truncate_account_revenue_facts
    ActiveRecord::Base.connection.execute('TRUNCATE account_revenue_facts RESTART IDENTITY')
  end

  def generate_account_revenue_facts
    time_dimensions = TimeDimension.all
    all_ios = Io.includes(
      :content_fees,
      :content_fee_product_budgets,
      :display_line_items,
      :display_line_item_budgets,
      io_members: :user
    )

    Client.find_each do |client|
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
          dominating_team = fetch_dominating_team(io)
          seller_names = fetch_user_presentations_by_dominating_team(io, dominating_team)

          client_revenue = client_revenues.find do |rev|
            rev[:time_dimension_id] == io_time_dimension.id &&
            rev[:team_name] == dominating_team.try(:name) &&
            rev[:seller_names] == seller_names
          end
          if client_revenue
            client_revenue[:revenue_amount] += time_period_revenue
          else
            client_revenues << {
              revenue_amount: time_period_revenue,
              time_dimension_id: io_time_dimension.id,
              team_name: dominating_team.try(:name),
              seller_names: seller_names
            }
          end
        end
      end

      client_revenues.each do |client_revenue|
        AccountRevenueFact.create(
          company_id: client.company_id,
          account_dimension_id: client.id,
          time_dimension_id: client_revenue[:time_dimension_id],
          team_name: client_revenue[:team_name],
          seller_names: "{#{client_revenue[:seller_names].join(', ')}}",
          category_id: client.client_category_id,
          subcategory_id: client.client_subcategory_id,
          client_region_id: client.client_region_id,
          client_segment_id: client.client_segment_id,
          revenue_amount: client_revenue[:revenue_amount]
        )
      end
    end
  end

  def fetch_dominating_team(io)
    io.highest_member&.user&.team
  end

  def fetch_user_presentations_by_dominating_team(io, dominating_team)
    return [] unless dominating_team

    io.io_members.select do |io_memeber|
      io_memeber.user.team_id == dominating_team.id && io_memeber.share > 0
    end.map do |io_memeber|
      "#{io_memeber.name} #{io_memeber.share}%"
    end.sort
  end

  def total_effective_revenue_budget(io, start_date, end_date)
    total_budget = 0
    io.content_fees.each do |content_fee|
      content_fee_product_budgets = content_fee.content_fee_product_budgets.select do |product_budget|
        product_budget.start_date <= end_date &&
        product_budget.end_date >= start_date
      end

      content_fee_product_budgets.each do |content_fee_product_budget|
        total_budget += content_fee_product_budget.corrected_daily_budget(io.start_date, io.end_date) * effective_days(start_date, end_date, [content_fee_product_budget])
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
      total_budget += in_budget_total + display_line_item.ave_run_rate * (effective_days(start_date, end_date, [display_line_item]) - in_budget_days)
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
