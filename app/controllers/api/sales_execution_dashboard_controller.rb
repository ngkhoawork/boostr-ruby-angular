class Api::SalesExecutionDashboardController < ApplicationController
  respond_to :json

  def index
    deal_ids = DealMember.where("user_id in (?)", params[:member_ids]).select(:deal_id).collect {|deal_member| deal_member.deal_id}

    top_deals = Deal.where('deals.id in (?)', deal_ids).open.more_than_percent(50).order("coalesce(budget, 0) desc").limit(10)

    start_date = Time.now.utc.beginning_of_week - 7.days
    end_date = Time.now.utc.beginning_of_week - 1.seconds
    pipeline_won = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(100).sum(:budget) / 100
    pipeline_lost = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(0).sum(:budget) / 100
    deals_lost = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).closed.closed_at(start_date, end_date).at_percent(0)
    pipeline_added = Deal.where('deals.id in (?) and deals.budget > 0', deal_ids).started_at(start_date, end_date).sum(:budget) / 100
    pipeline_advanced = DealLog.where('deal_id in (?)', deal_ids).for_time_period(start_date, end_date).sum(:budget_change) / 100

    week_pipeline_data = [
        {name: 'Added', value: pipeline_added, color:'#f8cbad'},
        {name: 'Advanced', value: pipeline_advanced, color:'#f4b183'},
        {name: 'Won', value: pipeline_won, color:'#a9d18e'},
        {name: 'Lost', value: pipeline_lost, color:'#bfbfbf'}
    ]

    probability_colors = { 90=> "#496a32", 75 => "#538233", 50 => "#62993e", 25 => "#70ad47", 10 => "#a1c490", 5 => "#c3d8bb"}
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

    render json: [{top_deals: top_deals, week_pipeline_data: week_pipeline_data, product_pipeline_data: {weighted: product_pipeline_data_weighted, unweighted: product_pipeline_data_unweighted}}]
  end

  def forecast
    start_date1 = Time.now.utc.beginning_of_quarter
    end_date1 = Time.now.utc.end_of_quarter.beginning_of_day
    start_date2 = (Time.now.utc + 3.months).beginning_of_quarter
    end_date2 = (Time.now.utc + 3.months).end_of_quarter.beginning_of_day
    puts "================"
    puts start_date1
    puts end_date1
    puts start_date2
    puts end_date2
    if member.present?
      render json: [ForecastMember.new(member, start_date1, end_date1), ForecastMember.new(member, start_date2, end_date2)]
    elsif team.present?
      render json: [ForecastTeam.new(team, start_date1, end_date1, nil, nil), ForecastTeam.new(team, start_date2, end_date2, nil, nil)]
    else
      render json: [Forecast.new(company, teams, start_date1, end_date1, nil), Forecast.new(company, teams, start_date2, end_date2, nil)]
    end
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

  def teams
    @teams ||= company.teams.roots(true)
  end

  def company
    @company ||= current_user.company
  end
end
