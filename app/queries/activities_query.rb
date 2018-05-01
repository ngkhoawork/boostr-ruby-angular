class ActivitiesQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_user_id(options[:member_id])
      .by_team_id(options[:team_id], options[:company_id])
      .by_activity_type_id(options[:activity_type_id])
      .by_happened_at(options[:start_date], options[:end_date])
  end

  private

  def default_relation
    Activity.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id ? where(company_id: company_id) : self
    end

    def by_user_id(user_id)
      user_id ? where(user_id: user_id) : self
    end

    def by_team_id(team_id, company_id)
      return self unless team_id && company_id

      team = Team.find_by!(id: team_id, company_id: company_id)

      by_user_id(team.all_members_and_leaders_ids)
    end

    def by_activity_type_id(activity_type_id)
      activity_type_id ? where(activity_type_id: activity_type_id) : self
    end

    def by_happened_at(start_date, end_date)
      return self unless start_date && end_date

      where('happened_at >= :start_date AND happened_at <= :end_date', start_date: start_date, end_date: end_date)
    end
  end
end
