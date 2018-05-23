class SpendAgreementsQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .fuzzy_search(options[:q])
      .my_records(options[:my_records], options[:current_user])
      .my_teams_records(options[:my_teams_records], options[:current_user])
      .manually_tracked(options[:manually_tracked])
      .min_target(options[:min_target])
      .max_target(options[:max_target])
      .for_time_period(options[:start_date], options[:end_date])
      .eager_load(:values, :holding_company, :parent_companies, :publishers, :clients)
      .by_type_id(options[:type_id])
      .by_status_id(options[:status_id])
      .by_client_ids(options[:by_client_ids])
      .pg_rank_grouping(options[:q])
      .distinct
  end

  private

  def default_relation
    SpendAgreement.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def pg_rank_grouping(query)
      query.nil? ? self : with_pg_search_rank
    end

    def my_records(bool, current_user)
      return self if bool.nil? || current_user.nil?

      by_member_id(current_user.id)
    end

    def my_teams_records(bool, current_user)
      return self if bool.nil? || current_user.nil?
      return by_leader_and_member_id(current_user) if current_user.leader?

      current_user.team_id.nil? ? none : by_team_id(current_user.team_id)
    end

    def by_member_id(member_id)
      member_id.nil? ? self : joins(:spend_agreement_team_members).where(spend_agreement_team_members: { user_id: member_id })
    end

    def by_team_id(team_id)
      team_id.nil? ? self : joins(:users).where(users: { team_id: team_id })
    end

    def by_leader_and_member_id(leader)
      by_member_id(leader_and_member_ids_for(leader)).uniq
    end

    def leader_and_member_ids_for(leader)
      Team.find_by(leader: leader).member_ids << leader.id
    end

    def manually_tracked(bool)
      bool.nil? ? self : where(manually_tracked: bool)
    end

    def min_target(value)
      value.nil? ? self : where('target >= ?', value)
    end

    def max_target(value)
      value.nil? ? self : where('target <= ?', value)
    end

    def for_time_period(start_date, end_date)
      return self if start_date.nil? || end_date.nil?

      where('start_date <= ? AND end_date >= ?', end_date, start_date)
    end

    def by_type_id(type_id)
      type_id.nil? ? self : where(type_id: type_id)
    end

    def by_status_id(status_id)
      status_id.nil? ? self : where(status_id: status_id)
    end

    def by_client_ids(ids)
      ids.nil? ? self : for_clients(ids)
    end
  end
end
