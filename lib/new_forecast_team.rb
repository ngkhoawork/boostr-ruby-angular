class NewForecastTeam
  include ActiveModel::SerializerSupport

  delegate :id, to: :team
  delegate :name, to: :team

  attr_accessor :team, :start_date, :end_date, :time_period, :product

  def initialize(team, time_period, product)
    self.team = team
    self.time_period = time_period
    self.start_date = time_period.start_date
    self.end_date = time_period.end_date
    self.product = product
  end

  def type
    'team'
  end

  def cache_key
    parts = []
    parts << team.id
    parts << team.updated_at
    parents.each do |parent|
      parts << parent[:id]
      parts << parent[:name]
    end
    # teams.each do |team|
    #   parts << team.cache_key
    # end
    # if leader
    #   parts << leader.cache_key
    # end
    # members.each do |member|
    #   parts << member.cache_key
    # end
    Digest::MD5.hexdigest(parts.join)
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

  def forecasts_data
    return @forecasts_data if defined?(@forecasts_data)

    time_dimension = TimeDimension.find_by(start_date: start_date, end_date: end_date)

    company = team.company

    @forecasts_data = {
      stages: company.stages,
      product: product ? {
        id: product.id,
        name: product.name
      } : nil,
      members: {},
      teams: {},
      revenue: 0.0,
      unweighted_pipeline_by_stage: {},
      unweighted_pipeline: 0.0,
      weighted_pipeline_by_stage: {},
      weighted_pipeline: 0.0,
      quota: 0.0,
    }
    user_ids = users.map{|user| user.id}
    user_ids.uniq!

    team_members = {}
    team.children.each do |child|
      child.all_members.each do |user|
        team_members[user.id] ||= []
        team_members[user.id] << child
      end
      child.all_leaders.each do |user|
        team_members[user.id] ||= []
        team_members[user.id] << child
      end
    end

    if product.nil?
      revenue_data = ForecastRevenueFact.where("time_dimension_id = ? AND user_dimension_id IN (?)", time_dimension.id, user_ids)
        .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
        .group("user_dimension_id")
      pipeline_data = ForecastPipelineFact.where("time_dimension_id = ? AND user_dimension_id IN (?)", time_dimension.id, user_ids)
        .select("user_dimension_id AS user_id, stage_dimension_id AS stage_id, SUM(amount) AS pipeline_amount")
        .group("user_dimension_id, stage_dimension_id")
    else
      revenue_data = ForecastRevenueFact.where("time_dimension_id = ? AND user_dimension_id IN (?) AND product_dimension_id = ?", time_dimension.id, user_ids, product.id)
        .select("user_dimension_id AS user_id, SUM(amount) AS revenue_amount")
        .group("user_dimension_id")
      pipeline_data = ForecastPipelineFact.where("time_dimension_id = ? AND user_dimension_id IN (?) AND product_dimension_id = ?", time_dimension.id, user_ids, product.id)
        .select("user_dimension_id AS user_id, stage_dimension_id AS stage_id, SUM(amount) AS pipeline_amount")
        .group("user_dimension_id, stage_dimension_id")
    end

    revenue_data.each do |item|
      user = company.users.find(item.user_id)
      @forecasts_data[:revenue] += item.revenue_amount.to_f
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          @forecasts_data[:teams][team.id] ||= {
            id: team.id,
            name: team.name,
            unweighted_pipeline: 0,
            weighted_pipeline: 0,
            unweighted_pipeline_by_stage: {},
            weighted_pipeline_by_stage: {},
            wow_weighted_pipeline: 0,
            revenue: 0,
            wow_revenue: 0,
            quota: 0
          }
          @forecasts_data[:teams][team.id][:revenue] ||= 0.0
          @forecasts_data[:teams][team.id][:revenue] += item.revenue_amount.to_f
        end
      else
        @forecasts_data[:members][item.user_id] ||= {
          id: user.id,
          name: user.name,
          is_leader: user.id == leader.id,
          unweighted_pipeline: 0,
          weighted_pipeline: 0,
          unweighted_pipeline_by_stage: {},
          weighted_pipeline_by_stage: {},
          wow_weighted_pipeline: 0,
          revenue: 0,
          wow_revenue: 0,
          quota: 0
        }
        @forecasts_data[:members][item.user_id][:revenue] ||= 0.0
        @forecasts_data[:members][item.user_id][:revenue] += item.revenue_amount.to_f
      end
      # @forecasts_data[:revenue] += item.revenue_amount.to_f
    end

    pipeline_data.each do |item|
      user = company.users.find(item.user_id)
      weighted_amount = item.pipeline_amount.to_f * company.stages.find(item.stage_id).probability.to_f / 100
      if team_members[item.user_id] && team_members[item.user_id].count > 0
        team_members[item.user_id].each do |team|
          @forecasts_data[:teams][team.id] ||= {
            id: team.id,
            name: team.name,
            unweighted_pipeline: 0,
            weighted_pipeline: 0,
            unweighted_pipeline_by_stage: {},
            weighted_pipeline_by_stage: {},
            wow_weighted_pipeline: 0,
            revenue: 0,
            wow_revenue: 0,
            quota: 0
          }

          @forecasts_data[:teams][team.id][:unweighted_pipeline] ||= 0.0
          @forecasts_data[:teams][team.id][:unweighted_pipeline] += item.pipeline_amount.to_f

          @forecasts_data[:teams][team.id][:unweighted_pipeline_by_stage] ||= {}
          @forecasts_data[:teams][team.id][:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
          @forecasts_data[:teams][team.id][:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount

          @forecasts_data[:teams][team.id][:weighted_pipeline] ||= 0.0
          @forecasts_data[:teams][team.id][:weighted_pipeline] += weighted_amount

          @forecasts_data[:teams][team.id][:weighted_pipeline_by_stage] ||= {}
          @forecasts_data[:teams][team.id][:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
          @forecasts_data[:teams][team.id][:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
        end
      else
        @forecasts_data[:members][item.user_id] ||= {
          id: user.id,
          name: user.name,
          is_leader: user.id == leader.id,
          unweighted_pipeline: 0,
          weighted_pipeline: 0,
          unweighted_pipeline_by_stage: {},
          weighted_pipeline_by_stage: {},
          wow_weighted_pipeline: 0,
          revenue: 0,
          wow_revenue: 0,
          quota: 0
        }

        @forecasts_data[:members][item.user_id][:unweighted_pipeline] ||= 0.0
        @forecasts_data[:members][item.user_id][:unweighted_pipeline] += item.pipeline_amount.to_f

        @forecasts_data[:members][item.user_id][:unweighted_pipeline_by_stage] ||= {}
        @forecasts_data[:members][item.user_id][:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
        @forecasts_data[:members][item.user_id][:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount


        @forecasts_data[:members][item.user_id][:weighted_pipeline] ||= 0.0
        @forecasts_data[:members][item.user_id][:weighted_pipeline] += weighted_amount

        @forecasts_data[:members][item.user_id][:weighted_pipeline_by_stage] ||= {}
        @forecasts_data[:members][item.user_id][:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
        @forecasts_data[:members][item.user_id][:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
      end

      @forecasts_data[:unweighted_pipeline] ||= 0.0
      @forecasts_data[:unweighted_pipeline] += item.pipeline_amount.to_f

      @forecasts_data[:unweighted_pipeline_by_stage] ||= {}
      @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
      @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount


      @forecasts_data[:weighted_pipeline] ||= 0.0
      @forecasts_data[:weighted_pipeline] += weighted_amount

      @forecasts_data[:weighted_pipeline_by_stage] ||= {}
      @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
      @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
    end

    users.each do |user|
      snapshots = user.snapshots.two_recent_for_time_period(start_date, end_date)
      wow_weighted_pipeline = (snapshots.first.weighted_pipeline - snapshots.last.weighted_pipeline rescue 0)
      wow_revenue = (snapshots.first.revenue - snapshots.last.revenue rescue 0)
      
      if team_members[user.id] && team_members[user.id].count > 0
        team_members[user.id].each do |team|
          @forecasts_data[:teams][team.id] ||= {
            id: team.id,
            name: team.name,
            unweighted_pipeline: 0,
            weighted_pipeline: 0,
            unweighted_pipeline_by_stage: {},
            weighted_pipeline_by_stage: {},
            wow_weighted_pipeline: 0,
            revenue: 0,
            wow_revenue: 0,
            quota: 0
          }
          @forecasts_data[:teams][team.id][:wow_weighted_pipeline] ||= 0.0
          @forecasts_data[:teams][team.id][:wow_weighted_pipeline] += wow_weighted_pipeline

          @forecasts_data[:teams][team.id][:wow_revenue] ||= 0.0
          @forecasts_data[:teams][team.id][:wow_revenue] += wow_revenue

        end
      else
        @forecasts_data[:members][user.id] ||= {
          id: user.id,
          name: user.name,
          is_leader: user.id == leader.id,
          unweighted_pipeline: 0,
          weighted_pipeline: 0,
          unweighted_pipeline_by_stage: {},
          weighted_pipeline_by_stage: {},
          wow_weighted_pipeline: 0,
          revenue: 0,
          wow_revenue: 0,
          quota: 0
        }
        @forecasts_data[:members][user.id][:wow_weighted_pipeline] ||= 0.0
        @forecasts_data[:members][user.id][:wow_weighted_pipeline] += wow_weighted_pipeline

        @forecasts_data[:members][user.id][:wow_revenue] ||= 0.0
        @forecasts_data[:members][user.id][:wow_revenue] += wow_revenue

        quota = user.quotas.for_time_period(start_date, end_date).sum(:value)
        @forecasts_data[:members][user.id][:quota] = quota
        @forecasts_data[:members][user.id][:amount] ||= (@forecasts_data[:members][user.id][:weighted_pipeline] || 0) + (@forecasts_data[:members][user.id][:revenue] || 0)
        @forecasts_data[:members][user.id][:percent_to_quota] ||= (quota > 0 ? @forecasts_data[:members][user.id][:amount] / quota * 100 : 100)
        @forecasts_data[:members][user.id][:percent_booked] ||= (quota > 0 ? @forecasts_data[:members][user.id][:revenue] / quota * 100 : 100)
        @forecasts_data[:members][user.id][:gap_to_quota] ||= (quota - @forecasts_data[:members][user.id][:amount]).to_f

        incomplete_deals ||= user.deals.active.closed.at_percent(0).closed_in(user.company.deals_needed_calculation_duration)
        complete_deals ||= user.deals.active.at_percent(100).closed_in(user.company.deals_needed_calculation_duration)
        if (incomplete_deals.count + complete_deals.count) > 0
          win_rate ||= (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
        else
          win_rate ||= 0.0
        end
        if complete_deals.count > 0
          average_deal_size = complete_deals.average(:budget).round(0)
        else
          average_deal_size = 0
        end
        if gap_to_quota <= 0
          new_deals_needed = 0
        elsif average_deal_size <= 0 or win_rate <= 0
          new_deals_needed = 'N/A'
        else
          new_deals_needed = (gap_to_quota / (win_rate * average_deal_size)).ceil
        end
        @forecasts_data[:members][user.id][:new_deals_needed] = new_deals_needed
      end

      @forecasts_data[:wow_weighted_pipeline] ||= 0.0
      @forecasts_data[:wow_weighted_pipeline] += wow_weighted_pipeline

      @forecasts_data[:wow_revenue] ||= 0.0
      @forecasts_data[:wow_revenue] += wow_revenue
    end

    team.children.each do |team|
      @forecasts_data[:teams][team.id] ||= {
        id: team.id,
        name: team.name,
        unweighted_pipeline: 0,
        weighted_pipeline: 0,
        unweighted_pipeline_by_stage: {},
        weighted_pipeline_by_stage: {},
        wow_weighted_pipeline: 0,
        revenue: 0,
        wow_revenue: 0,
        quota: 0
      }
      quota = (team.leader ? team.leader.quotas.for_time_period(start_date, end_date).sum(:value) : 0)
      @forecasts_data[:teams][team.id][:quota] ||= quota
      @forecasts_data[:teams][team.id][:amount] ||= (@forecasts_data[:teams][team.id][:weighted_pipeline] || 0) + (@forecasts_data[:teams][team.id][:revenue] || 0)
      @forecasts_data[:teams][team.id][:percent_to_quota] ||= (quota > 0 ? @forecasts_data[:teams][team.id][:amount] / quota * 100 : 100)
      @forecasts_data[:teams][team.id][:percent_booked] ||= (quota > 0 ? @forecasts_data[:teams][team.id][:revenue] / quota * 100 : 100)
      @forecasts_data[:teams][team.id][:gap_to_quota] ||= (quota - @forecasts_data[:teams][team.id][:amount]).to_f

      all_team_members = (team.all_members.nil? ? []:team.all_members)
      complete_dealsincomplete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_team_members.map{|member| member.id}).active.at_percent(100).closed_in(team.company.deals_needed_calculation_duration)
      incomplete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_team_members.map{|member| member.id}).active.closed.at_percent(0).closed_in(team.company.deals_needed_calculation_duration)
      if (incomplete_deals.count + complete_deals.count) > 0
        win_rate ||= (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
      else
        win_rate ||= 0.0
      end
      if complete_deals.count > 0
        average_deal_size = complete_deals.average(:budget).round(0)
      else
        average_deal_size = 0
      end
      if gap_to_quota <= 0
        new_deals_needed = 0
      elsif average_deal_size <= 0 or win_rate <= 0
        new_deals_needed = 'N/A'
      else
        new_deals_needed = (gap_to_quota / (win_rate * average_deal_size)).ceil
      end
      @forecasts_data[:teams][team.id][:new_deals_needed] = new_deals_needed
    end

    @forecasts_data
  end

  def weighted_pipeline_by_stage
    return @weighted_pipeline_by_stage if defined?(@weighted_pipeline_by_stage)

    @weighted_pipeline_by_stage = forecasts_data[:weighted_pipeline_by_stage]
    @weighted_pipeline_by_stage
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = forecasts_data[:weighted_pipeline]
    @weighted_pipeline
  end

  def unweighted_pipeline_by_stage
    return @unweighted_pipeline_by_stage if defined?(@unweighted_pipeline_by_stage)

    @unweighted_pipeline_by_stage = forecasts_data[:unweighted_pipeline_by_stage]
    @unweighted_pipeline_by_stage
  end

  def revenue
    return @revenue if defined?(@revenue)

    @revenue = forecasts_data[:revenue]
    @revenue
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
    # (users.sum{|user_item| (user_item.try(:wow_revenue) || 0)}).to_f
    # (teams.sum(&:wow_revenue) + members.sum(&:wow_revenue) + (leader.try(:wow_revenue) || 0)).to_f
  end

  def amount
    @amount ||= weighted_pipeline + revenue
    # (teams.sum(&:amount) + non_leader_members.sum(&:amount) + (leader.try(:amount) || 0)).to_f
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_booked
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def gap_to_quota
    (quota - amount).to_f
  end

  def quota
    return leader.quotas.for_time_period(start_date, end_date).sum(:value) if leader
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
    return 0 if goal <= 0
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota / (win_rate * average_deal_size)).ceil
    # return 0 if gap_to_quota <= 0
    # members_gap_to_quota = 0
    # new_deals = 0
    #
    # teams.each do |team|
    #   num = team.new_deals_needed
    #   members_gap_to_quota += team.gap_to_quota
    #   if num != 'N/A'
    #     new_deals += num
    #   end
    # end
    # return 'N/A' if new_deals == 'N/A'
    #
    # members.each do |member|
    #   next if leader and member.member == leader.member
    #   members_gap_to_quota += member.gap_to_quota
    #   if member.new_deals_needed != 'N/A'
    #     new_deals += member.new_deals_needed
    #   end
    #
    # end
    # return 'N/A' if new_deals == 'N/A'

    # leader_gap_to_quota = gap_to_quota - members_gap_to_quota
    #
    # if leader_gap_to_quota > 0
    #   if leader.win_rate > 0 and leader.average_deal_size > 0
    #     new_deals += (leader_gap_to_quota / (leader.win_rate * leader.average_deal_size)).ceil
    #   else
    #     return 'N/A'
    #   end
    # end
    # new_deals
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
