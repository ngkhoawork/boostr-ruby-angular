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
    start_date1 = Time.now.utc.beginning_of_quarter
    end_date1 = Time.now.utc.end_of_quarter.beginning_of_day
    start_date2 = (Time.now.utc + 3.months).beginning_of_quarter
    end_date2 = (Time.now.utc + 3.months).end_of_quarter.beginning_of_day
    if member.present?
      render json: [ForecastMember.new(member, start_date1, end_date1), ForecastMember.new(member, start_date2, end_date2)]
    elsif team.present?
      render json: [ForecastTeam.new(team, start_date1, end_date1, nil, nil), ForecastTeam.new(team, start_date2, end_date2, nil, nil)]
    else
      render json: [Forecast.new(company, teams, start_date1, end_date1, nil), Forecast.new(company, teams, start_date2, end_date2, nil)]
    end
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
    #
    # team_complete_deals = Deal.where("deals.id in (?)", team_deal_ids).closed_at(start_date, end_date).at_percent(100)
    # team_incomplete_deals = Deal.where("deals.id in (?)", team_deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    #
    # team_win_rate = 0.0
    # team_average_deal_size = 0
    # team_cycle_time = 0.0
    #
    # team_win_rate = (team_complete_deals.count.to_f / (team_complete_deals.count.to_f + team_incomplete_deals.count.to_f) * 100).round(2) if (team_incomplete_deals.count + team_complete_deals.count) > 0
    # team_average_deal_size = (team_complete_deals.average(:budget) / 1000.0).round(2) if team_complete_deals.count > 0
    # team_cycle_time_arr = team_complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s)  - Date.parse(deal.created_at.utc.to_s)}
    # team_cycle_time = (team_cycle_time_arr.sum.to_f / team_cycle_time_arr.count + 1).round(2) if team_cycle_time_arr.count > 0

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
    product_names = current_user.company.products.collect {|product| product.name}

    product_pipeline_data_weighted = []
    product_pipeline_data_unweighted = []

    probabilities.each do |probability|
      data = Deal.joins(:products).open_partial.at_percent(probability).where("products.company_id = ? and deals.id in (?)", current_user.company.id, deal_ids).group("products.id").order("products.id asc").select("products.name, sum(deal_products.budget) as total_budget").collect {|deal| {label: deal.name, value: deal.total_budget.to_i}}
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
    pipeline_advanced = DealLog.where('deal_id in (?)', deal_ids).for_time_period(start_date, end_date)
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
    deal_log_options = {
      include: {
        deal: {
          only: [:id, :name, :start_date, :budget, :budget_loc, :curr_cd],
            include: {
            advertiser: {
              only: [:id, :name]
            }
          }
        }
      }
    }

    @week_pipeline_data = [
        {name: 'Added', value: pipeline_added.sum(:budget).round, color:'#a4d0f0', deals: pipeline_added.as_json(options)},
        {name: 'Advanced', value: pipeline_advanced.sum(:budget_change).round, color:'#52a1e2', deals: pipeline_advanced.as_json(deal_log_options)},
        {name: 'Won', value: pipeline_won.sum(:budget).round, color:'#8ec536', deals: pipeline_won.as_json(options)},
        {name: 'Lost', value: pipeline_lost.sum(:budget).round, color:'#d2e8f8', deals: pipeline_lost.as_json(options)}
    ]

    @week_pipeline_data
  end

  def deal_ids
    @deal_ids = DealMember.where("user_id in (?)", params[:member_ids]).select(:deal_id).collect {|deal_member| deal_member.deal_id}
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
