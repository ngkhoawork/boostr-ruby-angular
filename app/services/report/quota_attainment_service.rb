class Report::QuotaAttainmentService
  include ActiveModel::Validations

  attr_accessor :company, :time_period_id, :user_status

  validate :validate_time_period

  def initialize(company, params)
    @time_period_id = params[:time_period_id]
    @company = company
    @user_status = params[:user_status].try(:downcase)
  end

  def perform
    generate_by_user_status
  end

  private

  def validate_time_period
    if time_period_id.nil?
      errors.add(:time_period_id, "can't be blank")
    elsif time_period.nil?
      errors.add(:time_period_id, "- #{time_period_id} can't be found")
    end
  end

  def generate_by_user_status
    generate_data(teams).first.select do |data|
      case user_status
        when 'active' 
          data[:is_active]
        when 'inactive' 
          !data[:is_active]
        else 
          true
      end
    end
  end

  def generate_data(teams)
    data = []
    leader_data = []

    teams.each do |team|
      parent_data = team_data(team)

      child_data, child_leader_data = generate_data(team.children)
      if team.leader.present?
        unless child_leader_data.empty?
          parent_data[team.leader_id] = leader_data(parent_data[team.leader_id], child_leader_data)
          parent_data[team.leader_id] = user_data(team.leader, team, parent_data[team.leader_id])
        end
        leader_data << parent_data[team.leader_id].slice(:revenue, :weighted_pipeline)
      else
        parent_leader_data = leader_data({}, parent_data.values)
        unless child_leader_data.empty?
          parent_leader_data = leader_data(parent_leader_data, child_leader_data)
        end
        leader_data << parent_leader_data
      end
      
      data += parent_data.values + child_data
    end

    [data, leader_data] 
  end

  def teams
    @teams ||= company.teams.roots(true)
  end

  def time_period
    @time_period ||= company.time_periods.find_by_id(time_period_id)
  end

  def start_date
    time_period.start_date
  end

  def end_date
    time_period.end_date
  end

  def forecast_time_dimension
    @forecast_time_dimension ||= ForecastTimeDimension.find_by(id: time_period.id) if time_period.present?
  end

  def forecast_gap_to_quota_positive
    company.forecast_gap_to_quota_positive
  end

  def revenue_data(user_ids)
    if forecast_time_dimension.present?
      ForecastRevenueFact.where("forecast_time_dimension_id = ? AND user_dimension_id IN (?)", forecast_time_dimension.id, user_ids)
        .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
        .group("user_dimension_id")
    else
      []
    end
  end

  def pipeline_data(user_ids)
    if forecast_time_dimension.present?
      ForecastPipelineFact
        .joins("LEFT JOIN stages ON stages.id = forecast_pipeline_facts.stage_dimension_id")
        .select("forecast_pipeline_facts.user_dimension_id AS user_id, forecast_pipeline_facts.stage_dimension_id as stage_id, AVG(stages.probability) AS probability, SUM(forecast_pipeline_facts.amount) AS pipeline_amount")
        .where("forecast_pipeline_facts.forecast_time_dimension_id = ? AND forecast_pipeline_facts.user_dimension_id IN (?)", forecast_time_dimension.id, user_ids)
        .group("forecast_pipeline_facts.user_dimension_id, forecast_pipeline_facts.stage_dimension_id")
    else
      []
    end
  end

  def user_data(user, team, data)
    data ||= init_record(user, team)
    data[:amount] = data[:weighted_pipeline] + data[:revenue]
    quota = user.total_gross_quotas(start_date, end_date)
    data[:quota] = quota
    data[:percent_to_quota] = (quota > 0 ? data[:amount] / quota * 100 : 100)
    data[:percent_booked] = (quota > 0 ? data[:revenue] / quota * 100 : 100)
    gap_to_quota = (quota - data[:amount]).to_f
    gap_to_quota = -gap_to_quota if !forecast_gap_to_quota_positive
    data[:gap_to_quota] = gap_to_quota
    data
  end

  def leader_data(data, child_data)
    data[:revenue] ||= 0
    data[:weighted_pipeline] ||= 0
    data[:revenue] += child_data.inject(0) {|sum, d| sum+d[:revenue]}
    data[:weighted_pipeline] += child_data.inject(0) {|sum, d| sum+d[:weighted_pipeline]}
    data
  end

  def init_record(user, team)
    {
      id: user.id,
      name: user.name,
      is_leader: user.leader?,
      is_active: user.is_active,
      team: team.slice(:id, :name),
      weighted_pipeline: 0,
      revenue: 0,
      quota: 0
    }
  end

  def team_data(team)
    users = []
    users << team.leader if team.leader.present?
    users += team.members
    user_ids = users.map(&:id).uniq

    data = revenue_data(user_ids).inject({}) do |data, item|
      user = users.detect {|user| user.id == item.user_id}
      data[user.id] ||= init_record(user, team)
      data[user.id][:revenue] += item.revenue_amount.to_f
      data
    end

    pipeline_data(user_ids).each do |item|
      user = users.detect {|user| user.id == item.user_id}
      data[user.id] ||= init_record(user, team)
      data[user.id][:weighted_pipeline] += item.pipeline_amount.to_f * item.probability.to_f / 100
    end

    if team.leader.present?
      data[team.leader_id] = leader_data(init_record(team.leader, team), data.values)
      data[team.leader_id] = user_data(team.leader, team, data[team.leader_id])
    end

    users.each do |user|
      data[user.id] = user_data(user, team, data[user.id])
    end

    data
  end
end
