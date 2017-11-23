class PublishersQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_comscore(options[:comscore])
      .by_stage_id(options[:publisher_stage_id])
      .by_type_id(options[:type_id])
      .by_team_id(options[:team_id])
      .by_created_at(options[:created_at])
      .my_publishers(options[:my_publishers_bool], options[:current_user])
      .my_team_publishers(options[:my_team_publishers_bool], options[:current_user])
      .search_by_name(options[:q])
      .order('created_at DESC')
  end

  private

  def default_relation
    Publisher.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def by_comscore(comscore)
      comscore.nil? ? self : where(comscore: comscore)
    end

    def by_stage_id(stage_id)
      stage_id.nil? ? self : where(publisher_stage_id: stage_id)
    end

    def by_type_id(type_id)
      type_id.nil? ? self : where(type_id: type_id)
    end

    def by_created_at(created_at)
      created_at.nil? ? self : where('date(created_at) = ?', created_at.to_date)
    end

    def by_member_id(member_id)
      member_id.nil? ? self : joins(:publisher_members).where(publisher_members: { user_id: member_id })
    end

    def by_team_id(team_id)
      team_id.nil? ? self : joins(:users).where(users: { team_id: team_id })
    end

    def my_publishers(my_publishers_bool, current_user)
      return self unless my_publishers_bool && current_user&.id

      by_member_id(current_user.id)
    end

    def my_team_publishers(my_team_publishers_bool, current_user)
      return self unless my_team_publishers_bool && current_user&.team_id

      by_team_id(current_user.team_id)
    end

    def search_by_name(q)
      q.present? ? super : self
    end
  end
end
