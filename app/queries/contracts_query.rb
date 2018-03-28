class ContractsQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_relation(options[:relation], options[:current_user])
      .by_user_id(options[:user_id])
      .by_team_id(options[:team_id])
      .by_advertiser_id(options[:advertiser_id])
      .by_agency_id(options[:agency_id])
      .by_client_id(options[:client_id])
      .by_deal_id(options[:deal_id])
      .by_holding_company_id(options[:holding_company_id])
      .by_type_id(options[:type_id])
      .by_status_id(options[:status_id])
      .by_start_date(options[:start_date_start], options[:start_date_end])
      .by_end_date(options[:end_date_start], options[:end_date_end])
      .search_by_name(options[:q])
  end

  private

  def default_relation
    Contract.all.extending(Scopes)
  end

  module Scopes
    def by_relation(relation, current_user)
      return self unless relation && current_user

      case relation
      when 'my'
        by_user_id(current_user.id)
      when 'my_teams'
        team = user_team(current_user)

        return none unless team

        by_team_id(team.id)
      when 'all'
        self
      end
    end

    def by_company_id(company_id)
      company_id ? where(company_id: company_id) : self
    end

    def by_user_id(user_id)
      return self unless user_id

      joins(:contract_members).where(contract_members: { user_id: user_id })
    end

    def by_team_id(team_id)
      return self unless team_id

      user_ids = users_by_team_id(team_id).pluck(:id)

      by_user_id(user_ids)
    end

    def by_agency_id(agency_id)
      agency_id ? where(agency_id: agency_id) : self
    end

    def by_advertiser_id(advertiser_id)
      advertiser_id ? where(advertiser_id: advertiser_id) : self
    end

    def by_client_id(client_id)
      return self unless client_id

      where("advertiser_id = :client_id OR agency_id = :client_id", client_id: client_id)
    end

    def by_deal_id(deal_id)
      deal_id ? where(deal_id: deal_id) : self
    end

    def by_holding_company_id(holding_company_id)
      holding_company_id ? where(holding_company_id: holding_company_id) : self
    end

    def by_type_id(type_id)
      type_id ? where(type_id: type_id) : self
    end

    def by_status_id(status_id)
      status_id ? where(status_id: status_id) : self
    end

    def by_start_date(start_date_start, start_date_end)
      return self if start_date_start.nil? || start_date_end.nil?

      where('start_date >= ? AND start_date <= ?', start_date_start, start_date_end)
    end

    def by_end_date(end_date_start, end_date_end)
      return self if end_date_start.nil? || end_date_end.nil?

      where('end_date >= ? AND end_date <= ?', end_date_start, end_date_end)
    end

    def search_by_name(q)
      q.present? ? super : self
    end

    private

    def users_by_team_id(team_id)
      Team.find(team_id).all_members_and_leaders
    end

    def user_team(user)
      user.teams[0] || user.team
    end
  end
end
