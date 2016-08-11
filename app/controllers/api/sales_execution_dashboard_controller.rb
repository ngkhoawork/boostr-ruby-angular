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
    .select("options.name as name, (sum(deals.budget) / 100) as total_budget")
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
    .where("deals.id in (?) and deals.budget > 0", deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    .select("prev_stages.name as name, count(deals.id) as count")
    .group("prev_stages.id")
    .order("count desc")
    .collect { |deal| {stage: deal.name, count: deal.count} }

    render json: deal_loss_data
  end

  protected

  def product_pipeline_data
    probability_colors = {
        90 => "#86c129",
        75 => "#a0ce56",
        50 => "#b3da76",
        25 => "#c3e78b",
        10 => "#d4f1a3",
        5 => "#e4ffb9"
    }
    # { 90=> "#3996db", 75 => "#52a1e2", 50 => "#7ab9e9", 25 => "#a4d0f0", 10 => "#d2e8f8", 5 => "#d2e8f8"}
    probabilities = current_user.company.distinct_stages.where("stages.probability > 0 and stages.probability < 100").order("stages.probability desc").collect { |stage| stage.probability }
    probabilities.reverse!
    product_names = current_user.company.products.collect {|product| product.name}

    product_pipeline_data_weighted = []
    product_pipeline_data_unweighted = []

    probabilities.each do |probability|
      data = Deal.joins(:products).open.at_percent(probability).where("products.company_id = ? and deals.id in (?)", current_user.company.id, deal_ids).group("products.id").order("products.id asc").select("products.name, (sum(deal_products.budget) / 100) as total_budget").collect {|deal| {label: deal.name, value: deal.total_budget}}
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
      product_pipeline_data_unweighted << {key: probability.to_s + '%', color: probability_colors[probability], values: final_data_unweighted}
      product_pipeline_data_weighted << {key: probability.to_s + '%', color: probability_colors[probability], values: final_data_weighted}
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
    pipeline_won = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(100).sum(:budget) / 100.0
    pipeline_lost = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(0).sum(:budget) / 100.0
    pipeline_added = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).started_at(start_date, end_date).sum(:budget) / 100.0
    pipeline_advanced = DealLog.where('deal_id in (?)', deal_ids).for_time_period(start_date, end_date).sum(:budget_change) / 100.0

    @week_pipeline_data = [
        {name: 'Added', value: pipeline_added.round, color:'#a4d0f0'},
        {name: 'Advanced', value: pipeline_advanced.round, color:'#52a1e2'},
        {name: 'Won', value: pipeline_won.round, color:'#8ec536'},
        {name: 'Lost', value: pipeline_lost.round, color:'#d2e8f8'}
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
