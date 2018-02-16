class Api::SalesExecutionDashboardController < ApplicationController
  respond_to :json

  def index
    render json: [
        {
            top_deals: top_deals,
            week_pipeline_data: week_pipeline_data,
            product_pipeline_data: product_pipeline_data,
            top_activities: top_activities
        }
    ]
  end

  def forecast
    render json: [current_forecast, next_quarter_forecast]
  rescue NoMethodError => _e
    render json: { errors: "Error happened when company didn't have time periods of type Quarter" },
                   status: :unprocessable_entity
  end

  def monthly_forecast
    if params[:start_date]
      start_date = Date.parse(params[:start_date])
    else
      start_date = Time.now.to_date.beginning_of_month
    end
    if params[:end_date]
      end_date = Date.parse(params[:end_date])
    else
      end_date = (start_date + 5.months).end_of_month
    end

    months = (start_date.to_date..end_date.to_date).map { |d| d.strftime("%b-%y") }.uniq

    if team.present?
      render json: { forecast: MonthlyForecastTeamSerializer.new(ForecastTeam.new(team, start_date, end_date, nil, nil)), months: months }
    else
      render json: { forecast: MonthlyForecastSerializer.new(Forecast.new(company, teams, start_date, end_date, nil)), months: months }
    end
  end

  def kpis
    case params[:time_period]
      when "all_time"
        end_date = Time.now.utc
        start_date = DateTime.parse("2014-01-01")
      when "last_qtr"
        end_date = Time.now.utc.beginning_of_quarter - 1.seconds
        start_date = end_date.beginning_of_quarter
      when "qtd"
        start_date = Time.now.utc.beginning_of_quarter
        end_date = Time.now.utc
    end

    complete_deals = Deal.where("deals.id in (?)", deal_ids).active.closed_at(start_date, end_date).at_percent(100)
    incomplete_deals = Deal.where("deals.id in (?)", deal_ids).active.closed.closed_at(start_date, end_date).at_percent(0)

    win_rate = 0.0
    average_deal_size = 0
    cycle_time = 0.0

    win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0
    average_deal_size = (complete_deals.average(:budget) / 1000.0).round(0) if complete_deals.count > 0
    cycle_time_arr = complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s)  - Date.parse(deal.created_at.utc.to_s)}
    cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1).round(0) if cycle_time_arr.count > 0

    render json: [{win_rate: win_rate, average_deal_size: average_deal_size, cycle_time: cycle_time}]
  end

  def deal_loss_summary
    case params[:time_period]
      when "last_week"
        start_date = Time.now.utc.beginning_of_week - 7.days
        end_date = Time.now.utc.beginning_of_week - 1.seconds
      when "this_week"
        start_date = Time.now.utc.beginning_of_week
        end_date = Time.now.utc
      when "qtd"
        start_date = Time.now.utc.beginning_of_quarter
        end_date = Time.now.utc
    end

    deal_loss_data = Deal.joins("left join values on deals.id=values.subject_id and values.subject_type='Deal'")
    .joins("left join fields on  values.field_id=fields.id")
    .joins("left join options on options.id=values.option_id")
    .where("deals.id in (?) and deals.budget > 0 and fields.name='Close Reason'", deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    .select("options.name as name, sum(deals.budget) as total_budget")
    .group("options.name")
    .order("total_budget desc")
    .collect { |deal| {reason: deal.name, total_budget: deal.total_budget} }

    render json: deal_loss_data
  end

  def activity_summary
    case params[:time_period]
      when "last_week"
        start_date = Time.now.utc.beginning_of_week - 7.days
        end_date = Time.now.utc.beginning_of_week - 1.seconds
      when "this_week"
        start_date = Time.now.utc.beginning_of_week
        end_date = Time.now.utc
      when "qtd"
        start_date = Time.now.utc.beginning_of_quarter
        end_date = Time.now.utc
    end
    activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
    .where("user_id in (?) and happened_at >= ? and happened_at <= ?", params[:member_ids], start_date, end_date)
    .select("activity_types.name, count(activities.id) as count")
    .group("activity_types.name")
    .order("activities.count desc")
    .collect { |activity| {activity: activity.name, count: activity.count} }

    render json: activities
  end


  def deal_loss_stages
    case params[:time_period]
      when "last_week"
        start_date = Time.now.utc.beginning_of_week - 7.days
        end_date = Time.now.utc.beginning_of_week - 1.seconds
      when "this_week"
        start_date = Time.now.utc.beginning_of_week
        end_date = Time.now.utc
      when "qtd"
        start_date = Time.now.utc.beginning_of_quarter
        end_date = Time.now.utc
    end
    deal_loss_data = Deal.joins("left join stages as prev_stages on prev_stages.id=deals.previous_stage_id")
    .where("deals.id in (?) and deals.budget > 0 and deals.previous_stage_id IS NOT NULL", deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    .select("prev_stages.name as name, count(deals.id) as count")
    .group("prev_stages.id")
    .order("count desc")
    .collect { |deal| {stage: deal.name, count: deal.count} }

    render json: deal_loss_data
  end

  protected

  def stage_color(probability)
    if probability == 100
      color_string = "rgb(110, 150, 20)";
    else
      red = 229 - 100 * probability / 100
      green = 255 - 78 * probability / 100
      blue = 185 - 160 * probability / 100
      color_string = "rgb(#{red}, #{green}, #{blue})";
    end
  end

  def product_pipeline_data
    probabilities = current_user.company.distinct_stages.where("stages.probability > 0").order("stages.probability desc").collect { |stage| stage.probability }
    probabilities.reverse!
    product_names = current_user.company.products.active.collect {|product| product.name}

    product_pipeline_data_weighted = []
    product_pipeline_data_unweighted = []

    probabilities.each do |probability|
      data = Deal.joins(:products)
                 .open_partial.at_percent(probability)
                 .where("products.company_id = ? and deals.id in (?)", current_user.company.id, deal_ids)
                 .where('products.active IS true')
                 .group("products.id")
                 .order("products.id asc")
                 .select("products.name, sum(deal_products.budget) as total_budget")
                 .collect {|deal| {label: deal.name, value: deal.total_budget.to_i}}
      final_data_weighted = []
      final_data_unweighted = []
      product_names.each do |product_name|
        row = data.select {|row| row[:label] == product_name }
        if row.count > 0
          final_data_weighted << {label: row[0][:label], value: row[0][:value] * probability / 100}
          final_data_unweighted << row[0]
        else
          final_data_weighted << {label: product_name, value: 0}
          final_data_unweighted << {label: product_name, value: 0}
        end
      end
      product_pipeline_data_unweighted << {key: probability.to_s + '%', color: stage_color(probability), values: final_data_unweighted}
      product_pipeline_data_weighted << {key: probability.to_s + '%', color: stage_color(probability), values: final_data_weighted}
    end

    @product_pipeline_data = {
        weighted: product_pipeline_data_weighted,
        unweighted: product_pipeline_data_unweighted
    }

    @product_pipeline_data
  end

  def week_pipeline_data
    start_date = Time.now.utc.beginning_of_week - 7.days
    end_date = Time.now.utc.beginning_of_week - 1.seconds
    pipeline_won = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(100)
    pipeline_lost = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    pipeline_added = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).started_at(start_date, end_date)
    pipeline_advanced_audit = AuditLog.by_auditable_type('Deal')
                                      .by_type_of_change(AuditLog::BUDGET_CHANGE_TYPE)
                                      .where(auditable_id: deal_ids)
                                      .in_created_at_range(start_date..end_date)

    pipeline_advanced_audit_deals =
      pipeline_advanced_audit
        .joins('LEFT JOIN deals ON audit_logs.auditable_id = deals.id')
        .group('deals.id, audit_logs.changed_amount')
        .select('deals.id, deals.name, deals.start_date, deals.advertiser_id, sum(audit_logs.changed_amount) as total_changed_amount')
        .reduce([]) do |data, item|
          repeated_tem = data.find { |i| i[:id].eql? item.id }

          if repeated_tem.present?
            repeated_tem[:budget] += item.total_changed_amount
            data
          else
            data << {
              id: item.id,
              name: item.name,
              start_date: item.start_date,
              budget: item.total_changed_amount,
              advertiser: Client.find(item.advertiser_id).as_json({override: true, only: [:id, :name] })
            }
          end
        end

    options = {
      override: true,
      options: {
        only: [:id, :name, :start_date, :budget, :budget_loc, :curr_cd],
        include: {
          advertiser: {
            only: [:id, :name]
          }
        }
      }
    }

    @week_pipeline_data = [
        {name: 'Added', value: pipeline_added.sum(:budget).round, color:'#a4d0f0', deals: pipeline_added.as_json(options)},
        {name: 'Advanced', value: pipeline_advanced_audit.sum(:changed_amount).round, color:'#52a1e2', deals: pipeline_advanced_audit_deals},
        {name: 'Won', value: pipeline_won.sum(:budget).round, color:'#8ec536', deals: pipeline_won.as_json(options)},
        {name: 'Lost', value: pipeline_lost.sum(:budget).round, color:'#d2e8f8', deals: pipeline_lost.as_json(options)}
    ]

    @week_pipeline_data
  end

  def deal_ids
    @_deal_ids = DealMember.where(user_id: params[:member_ids]).pluck(:deal_id)
  end

  def top_deals
    @top_deals = Deal.where('deals.id in (?)', deal_ids).open.more_than_percent(50).order("coalesce(budget, 0) desc").limit(10)
  end

  def team
    @team ||= current_user.company.teams.where(id: params[:team_id]).first
  end

  def member
    @user ||= current_user.company.users.where(id: params[:member_id]).first
  end

  def products
    @products ||= current_user.company.products
  end

  def time_period
    @_time_period ||= company.time_periods.current_quarter
  end

  def next_time_period
    company.time_periods.all_quarter.find_by(start_date: time_period.end_date.next)
  end

  def current_forecast
    return nil unless time_period

    @_forecast ||= forecast_for(time_period)
  end

  def company_teams
    @_teams = company.teams.roots(true)
  end

  def next_quarter_forecast
    return nil unless time_period || next_time_period

    @_next_quarter_forecast ||= forecast_for(next_time_period)
  end

  def forecast_for(period)
    if member.present?
      NewForecastMember.new(member, period, nil)
    elsif team.present?
      NewForecastTeam.new(team, period, nil)
    else
      NewForecast.new(company, company_teams, period, nil)
    end
  end

  def top_activities
    @top_activities ||= Activity.where("user_id in (?) and happened_at >= ?", params[:member_ids], Time.now.utc).limit(10)
  end

  def teams
    @teams ||= company.teams.roots(true)
  end

  def company
    @company ||= current_user.company
  end
end
