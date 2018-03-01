class NewForecastTeam
  include ActiveModel::SerializerSupport

  delegate :id, to: :team
  delegate :name, to: :team

  attr_accessor :team, :start_date, :end_date, :time_period, :product_family, :product, :quarter, :year

  def initialize(team, time_period, product_family = nil, product = nil, quarter = nil, year = nil)
    self.team = team
    self.time_period = time_period
    self.start_date = time_period.start_date
    self.end_date = time_period.end_date
    self.product_family = product_family
    self.product = product
    self.quarter = quarter
    self.year = year
  end

  def type
    'team'
  end

  def company
    @_company ||= team.company
  end

  def forecast_gap_to_quota_positive
    @_forecast_gap_to_quota_positive ||= company.forecast_gap_to_quota_positive
  end

  def parents
    return @parents if defined?(@parents)
    @parents = []
    parent = team.parent
    loop do
      break if parent.nil?
      @parents <<  {id: parent.id, name: parent.name}
      parent = parent.parent
    end
    @parents = @parents.reverse
  end

  def teams
    return @teams if defined?(@teams)
    @teams = []
    forecasts_data[:teams].each do |index, item|
      @teams << item
    end
    @teams
  end

  def leader
    @leader ||= team.leader
  end

  def stages
    return @stages if defined?(@stages)
    ids = weighted_pipeline_by_stage.keys
    @stages = team.company.stages.where(id: ids).order(:probability).all
  end

  def members
    return @members if defined?(@members)
    @members = []
    forecasts_data[:members].each do |index, item|
      item[:id] = index
      @members << item
    end
    @members
  end

  def users
    return @users if defined?(@users)
    users = team.all_members + team.all_leaders
  end

  def user_ids
    @_user_ids ||= users.map(&:id).uniq
  end

  def quarters
    return @quarters if defined?(@quarters)

    @quarters = []
    @quarters << { start_date: Time.new(year, 1, 1), end_date: Time.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Time.new(year, 4, 1), end_date: Time.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Time.new(year, 7, 1), end_date: Time.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Time.new(year, 10, 1), end_date: Time.new(year, 12, 31), quarter: 4 }
    @quarters
  end

  def non_leader_members
    @non_leader_members ||= members.reject{ |m| m.member.leader? }
  end

  def team_members
    @_team_members ||= team.children.inject({}) do |result, child|
      child.all_members.each do |user|
        result[user.id] ||= []
        result[user.id] << child
      end
      child.all_leaders.each do |user|
        result[user.id] ||= []
        result[user.id] << child
      end
      result
    end
  end

  def forecasts_data
    return @forecasts_data if defined?(@forecasts_data)

    @forecasts_data = forecast_initial_data

    add_revenue_data(@forecasts_data)

    add_pmp_revenue_data(@forecasts_data)

    deduct_cost_revenue_data(@forecasts_data) if company.enable_net_forecasting

    add_pipeline_data(@forecasts_data)

    add_pipeline_data(@forecasts_data, true)

    add_user_data(@forecasts_data)

    add_team_data(@forecasts_data)

    @forecasts_data
  end

  def pmp_revenue_data
    @_pmp_revenue_data ||= ForecastPmpRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
      .group("user_dimension_id")
  end

  def revenue_data
    @_revenue_data ||= ForecastRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
      .group("user_dimension_id")
  end

  def cost_revenue_data
    @_cost_revenue_data ||= ForecastCostFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
      .group("user_dimension_id")
  end

  def pipeline_data
    @_pipeline_data ||= ForecastPipelineFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("user_dimension_id AS user_id, stage_dimension_id AS stage_id, SUM(amount) AS pipeline_amount")
      .group("user_dimension_id, stage_dimension_id")
  end

  def pipeline_data_net
    @_pipeline_data_net ||= if company.enable_net_forecasting
      ForecastPipelineFact
        .joins("LEFT JOIN products ON forecast_pipeline_facts.product_dimension_id = products.id")
        .by_time_dimension_id(forecast_time_dimension.id)
        .by_user_dimension_ids(user_ids)
        .by_product_dimension_ids(product_ids)
        .select("forecast_pipeline_facts.user_dimension_id AS user_id, 
          forecast_pipeline_facts.stage_dimension_id AS stage_id, 
          SUM(forecast_pipeline_facts.amount * products.margin / 100) AS pipeline_amount")
        .group("forecast_pipeline_facts.user_dimension_id, 
          forecast_pipeline_facts.stage_dimension_id")
    end
  end

  def forecast_time_dimension
    @_forecast_time_dimension ||= ForecastTimeDimension.find_by(id: time_period.id)
  end

  def forecast_initial_data
    {
      stages: company.stages,
      product: product ? {
        id: product.id,
        name: product.name
      } : nil,
      members: {},
      teams: {},
      quarter: quarter,
      year: year,
      revenue: 0.0,
      unweighted_pipeline_by_stage: {},
      unweighted_pipeline: 0.0,
      weighted_pipeline_by_stage: {},
      weighted_pipeline: 0.0,
      quota: 0.0,
    }
  end

  def build_team_data(team)
    {
      id: team.id,
      name: team.name,
      type: 'team',
      quarter: quarter,
      year: year,
      unweighted_pipeline: 0,
      weighted_pipeline: 0,
      unweighted_pipeline_by_stage: {},
      weighted_pipeline_by_stage: {},
      unweighted_pipeline_net: 0,
      weighted_pipeline_net: 0,
      unweighted_pipeline_by_stage_net: {},
      weighted_pipeline_by_stage_net: {},
      wow_weighted_pipeline: 0,
      revenue: 0,
      revenue_net: 0,
      wow_revenue: 0,
      quota: 0
    }
  end

  def build_member_data(user)
    {
      id: user.id,
      name: user.name,
      is_leader: user.leader?,
      type: 'member',
      quarter: quarter,
      year: year,
      unweighted_pipeline: 0,
      weighted_pipeline: 0,
      unweighted_pipeline_by_stage: {},
      weighted_pipeline_by_stage: {},
      unweighted_pipeline_net: 0,
      weighted_pipeline_net: 0,
      unweighted_pipeline_by_stage_net: {},
      weighted_pipeline_by_stage_net: {},
      wow_weighted_pipeline: 0,
      revenue: 0,
      revenue_net: 0,
      wow_revenue: 0,
      quota: 0
    }
  end

  def add_revenue_data(data)
    revenue_data.each do |item|
      user = company.users.find(item.user_id)
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          data[:teams][team.id] ||= build_team_data(team)
          add_revenue_item(data[:teams][team.id], item)
        end
      else
        data[:members][item.user_id] ||= build_member_data(user)
        add_revenue_item(data[:members][item.user_id], item)
      end

      add_revenue_item(data, item)
    end
  end

  def add_pmp_revenue_data(data)
    pmp_revenue_data.each do |item|
      user = company.users.find(item.user_id)
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          data[:teams][team.id] ||= build_team_data(team)
          add_revenue_item(data[:teams][team.id], item)
        end
      else
        data[:members][item.user_id] ||= build_member_data(user)
        add_revenue_item(data[:members][item.user_id], item)
      end

      add_revenue_item(data, item)
    end
  end

  def deduct_cost_revenue_data(data)
    cost_revenue_data.each do |item|
      user = company.users.find(item.user_id)
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          data[:teams][team.id] ||= build_team_data(team)
          deduct_revenue_item(data[:teams][team.id], item)
        end
      else
        data[:members][item.user_id] ||= build_member_data(user)
        deduct_revenue_item(data[:members][item.user_id], item)
      end

      deduct_revenue_item(data, item)
    end
  end

  def add_revenue_item(data, item)
    data[:revenue] ||= 0.0
    data[:revenue] += item.revenue_amount.to_f
    data[:revenue_net] ||= 0.0
    data[:revenue_net] += item.revenue_amount.to_f
  end

  def deduct_revenue_item(data, item)
    data[:revenue_net] ||= 0.0
    data[:revenue_net] -= item.revenue_amount.to_f
  end

  def add_pipeline_data(data, isNetForecast = false)
    source_data = isNetForecast ? pipeline_data_net : pipeline_data
    return if !source_data
    source_data.each do |item|
      user = company.users.find(item.user_id)
      weighted_amount = item.pipeline_amount.to_f * company.stages.find(item.stage_id).probability.to_f / 100
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          data[:teams][team.id] ||= build_team_data(team)
          if isNetForecast
            add_pipeline_net_item(data[:teams][team.id], item, weighted_amount)
          else
            add_pipeline_item(data[:teams][team.id], item, weighted_amount)
          end
        end
      else
        data[:members][item.user_id] ||= build_member_data(user)
        if isNetForecast
          add_pipeline_net_item(data[:members][item.user_id], item, weighted_amount)
        else
          add_pipeline_item(data[:members][item.user_id], item, weighted_amount)
        end
        
      end
      if isNetForecast
        add_pipeline_net_item(data, item, weighted_amount)
      else
        add_pipeline_item(data, item, weighted_amount)
      end
      
    end
  end

  def add_pipeline_item(data, item, weighted_amount)
    data[:unweighted_pipeline] ||= 0.0
    data[:unweighted_pipeline] += item.pipeline_amount.to_f

    data[:unweighted_pipeline_by_stage] ||= {}
    data[:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
    data[:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount

    data[:weighted_pipeline] ||= 0.0
    data[:weighted_pipeline] += weighted_amount

    data[:weighted_pipeline_by_stage] ||= {}
    data[:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
    data[:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
  end

  def add_pipeline_net_item(data, item, weighted_amount)
    data[:unweighted_pipeline_net] ||= 0.0
    data[:unweighted_pipeline_net] += item.pipeline_amount.to_f

    data[:unweighted_pipeline_by_stage_net] ||= {}
    data[:unweighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    data[:unweighted_pipeline_by_stage_net][item.stage_id] += item.pipeline_amount

    data[:weighted_pipeline_net] ||= 0.0
    data[:weighted_pipeline_net] += weighted_amount

    data[:weighted_pipeline_by_stage_net] ||= {}
    data[:weighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    data[:weighted_pipeline_by_stage_net][item.stage_id] += weighted_amount
  end

  def add_user_data(data)
    users.each do |user|
      snapshots = user.snapshots.two_recent_for_time_period(start_date, end_date)
      wow_weighted_pipeline = (snapshots.first.weighted_pipeline - snapshots.last.weighted_pipeline rescue 0)
      wow_revenue = (snapshots.first.revenue - snapshots.last.revenue rescue 0)
      
      if team_members[user.id] && team_members[user.id].count > 0
        team_members[user.id].each do |team|
          data[:teams][team.id] ||= build_team_data(team)
          add_wow_data(data[:teams][team.id], wow_weighted_pipeline, wow_revenue)
        end
      else
        data[:members][user.id] ||= build_member_data(user)
        add_wow_data(data[:members][user.id], wow_weighted_pipeline, wow_revenue)
        add_user_other_data(data[:members][user.id], user)
      end

      add_wow_data(data, wow_weighted_pipeline, wow_revenue)
    end
  end

  def add_team_data(data)
    team.children.each do |team|
      data[:teams][team.id] ||= build_team_data(team)
      add_team_other_data(data[:teams][team.id], team)
    end
  end

  def add_user_other_data(data, user)
    quota = user.total_gross_quotas(start_date, end_date)

    if user.leader?
      data[:quota] = 0
    else
      data[:quota] = quota
    end
    data[:amount] = (data[:weighted_pipeline] || 0) + (data[:revenue] || 0)
    data[:amount_net] = (data[:weighted_pipeline_net] || 0) + (data[:revenue_net] || 0)

    gap_to_quota = (quota - data[:amount]).to_f
    gap_to_quota = -gap_to_quota if !forecast_gap_to_quota_positive

    gap_to_quota_net = (quota - data[:amount_net]).to_f
    gap_to_quota_net = -gap_to_quota_net if !forecast_gap_to_quota_positive

    data[:percent_to_quota] = (quota > 0 ? data[:amount] / quota * 100 : 100)
    data[:percent_booked] = (quota > 0 ? data[:revenue] / quota * 100 : 100)
    data[:gap_to_quota] = gap_to_quota

    data[:percent_to_quota_net] = (quota > 0 ? data[:amount_net] / quota * 100 : 100)
    data[:percent_booked_net] = (quota > 0 ? data[:revenue_net] / quota * 100 : 100)
    data[:gap_to_quota_net] = gap_to_quota_net

    incomplete_deals = user.deals.active.closed.at_percent(0).closed_in(user.company.deals_needed_calculation_duration)
    complete_deals = user.deals.active.at_percent(100).closed_in(user.company.deals_needed_calculation_duration)
    if (incomplete_deals.count + complete_deals.count) > 0
      win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
    else
      win_rate = 0.0
    end
    if complete_deals.count > 0
      average_deal_size = complete_deals.average(:budget).round(0)
    else
      average_deal_size = 0
    end

    if gap_to_quota <= 0 && forecast_gap_to_quota_positive
      new_deals_needed = 0
    elsif gap_to_quota > 0 && !forecast_gap_to_quota_positive
      new_deals_needed = 0
    elsif average_deal_size <= 0 or win_rate <= 0
      new_deals_needed = 'N/A'
    else
      new_deals_needed = (gap_to_quota.abs / (win_rate * average_deal_size)).ceil
    end

    data[:new_deals_needed] = new_deals_needed
  end

  def add_team_other_data(data, team)
    quota = (team.leader ? team.leader.total_gross_quotas(start_date, end_date) : 0)

    data[:quota] = quota
    data[:amount] = (data[:weighted_pipeline] || 0) + (data[:revenue] || 0)
    data[:amount_net] = (data[:weighted_pipeline_net] || 0) + (data[:revenue_net] || 0)

    gap_to_quota = (quota - data[:amount]).to_f
    gap_to_quota = -gap_to_quota if !forecast_gap_to_quota_positive
    gap_to_quota_net = (quota - data[:amount_net]).to_f
    gap_to_quota_net = -gap_to_quota_net if !forecast_gap_to_quota_positive

    data[:percent_to_quota] = (quota > 0 ? data[:amount] / quota * 100 : 100)
    data[:percent_booked] = (quota > 0 ? data[:revenue] / quota * 100 : 100)
    data[:gap_to_quota] = gap_to_quota
    data[:percent_to_quota_net] = (quota > 0 ? data[:amount_net] / quota * 100 : 100)
    data[:percent_booked_net] = (quota > 0 ? data[:revenue_net] / quota * 100 : 100)
    data[:gap_to_quota_net] = gap_to_quota_net

    all_team_members = (team.all_members.nil? ? []:team.all_members)
    complete_deals = Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_team_members.map{|member| member.id}).active.at_percent(100).closed_in(team.company.deals_needed_calculation_duration)
    incomplete_deals = Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_team_members.map{|member| member.id}).active.closed.at_percent(0).closed_in(team.company.deals_needed_calculation_duration)
    if (incomplete_deals.count + complete_deals.count) > 0
      win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
    else
      win_rate = 0.0
    end
    if complete_deals.count > 0
      average_deal_size = complete_deals.average(:budget).round(0)
    else
      average_deal_size = 0
    end
    
    if gap_to_quota <= 0 && forecast_gap_to_quota_positive
      new_deals_needed = 0
    elsif gap_to_quota > 0 && !forecast_gap_to_quota_positive
      new_deals_needed = 0
    elsif average_deal_size <= 0 or win_rate <= 0
      new_deals_needed = 'N/A'
    else
      new_deals_needed = (gap_to_quota.abs / (win_rate * average_deal_size)).ceil
    end
    data[:new_deals_needed] = new_deals_needed
  end

  def add_wow_data(data, wow_weighted_pipeline, wow_revenue)
    data[:wow_weighted_pipeline] ||= 0.0
    data[:wow_weighted_pipeline] += wow_weighted_pipeline

    data[:wow_revenue] ||= 0.0
    data[:wow_revenue] += wow_revenue
  end

  def weighted_pipeline_by_stage
    return @weighted_pipeline_by_stage if defined?(@weighted_pipeline_by_stage)

    @weighted_pipeline_by_stage = forecasts_data[:weighted_pipeline_by_stage]
    @weighted_pipeline_by_stage
  end

  def weighted_pipeline_by_stage_net
    return @weighted_pipeline_by_stage_net if defined?(@weighted_pipeline_by_stage_net)

    @weighted_pipeline_by_stage_net = forecasts_data[:weighted_pipeline_by_stage_net]
    @weighted_pipeline_by_stage_net
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = forecasts_data[:weighted_pipeline]
    @weighted_pipeline
  end

  def weighted_pipeline_net
    return @weighted_pipeline_net if defined?(@weighted_pipeline_net)

    @weighted_pipeline_net = forecasts_data[:weighted_pipeline_net] || 0
    @weighted_pipeline_net
  end

  def unweighted_pipeline_by_stage
    return @unweighted_pipeline_by_stage if defined?(@unweighted_pipeline_by_stage)

    @unweighted_pipeline_by_stage = forecasts_data[:unweighted_pipeline_by_stage]
    @unweighted_pipeline_by_stage
  end

  def unweighted_pipeline_by_stage_net
    return @unweighted_pipeline_by_stage_net if defined?(@unweighted_pipeline_by_stage_net)

    @unweighted_pipeline_by_stage_net = forecasts_data[:unweighted_pipeline_by_stage_net]
    @unweighted_pipeline_by_stage_net
  end

  def revenue
    return @revenue if defined?(@revenue)

    @revenue = forecasts_data[:revenue]
    @revenue
  end

  def revenue_net
    return @revenue_net if defined?(@revenue_net)

    @revenue_net = forecasts_data[:revenue_net]
    @revenue_net
  end

  def wow_weighted_pipeline
    return @wow_weighted_pipeline if defined?(@wow_weighted_pipeline)

    @wow_weighted_pipeline = forecasts_data[:wow_weighted_pipeline]
    @wow_weighted_pipeline
  end

  def wow_revenue
    return @wow_revenue if defined?(@wow_revenue)

    @wow_revenue = forecasts_data[:wow_revenue]
    @wow_revenue
  end

  def amount
    @_amount ||= weighted_pipeline + revenue
  end

  def amount_net
    @_amount_net ||= weighted_pipeline_net + revenue_net
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_to_quota_net
    return 100 unless quota > 0
    amount_net / quota * 100
  end

  def percent_booked
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def percent_booked_net
    return 100 unless quota > 0
    revenue_net / quota * 100
  end

  def gap_to_quota
    if team.company.forecast_gap_to_quota_positive
      return (quota - amount).to_f
    else
      return (amount - quota).to_f
    end
  end

  def gap_to_quota_net
    if team.company.forecast_gap_to_quota_positive
      return (quota - amount_net).to_f
    else
      return (amount_net - quota).to_f
    end
  end

  def quota
    return leader.total_gross_quotas(start_date, end_date) if leader
    0
  end

  def win_rate
    if (incomplete_deals.count + complete_deals.count) > 0
      @win_rate ||= (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
    else
      @win_rate ||= 0.0
    end
  end

  def average_deal_size
    if complete_deals.count > 0
      @average_deal_size ||= complete_deals.average(:budget).round(0)
    else
      @average_deal_size ||= 0
    end
  end

  def new_deals_needed
    goal = gap_to_quota
    return 0 if goal <= 0 && team.company.forecast_gap_to_quota_positive
    return 0 if goal > 0 && !team.company.forecast_gap_to_quota_positive
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota.abs / (win_rate * average_deal_size)).ceil
  end

  def product_ids
    @_product_ids ||= if product.present?
      [product.id]
    elsif product_family.present?
      product_family.products.collect(&:id)
    end
  end

  def complete_deals
    @complete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.at_percent(100).closed_in(team.company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.closed.at_percent(0).closed_in(team.company.deals_needed_calculation_duration)
  end

  def all_teammembers
    (team.all_members.nil? ? []:team.all_members) + (team.all_leaders.nil? ? []:team.all_leaders)
  end

  def all_members
    (team.all_members.nil? ? []:team.all_members)
  end
end
