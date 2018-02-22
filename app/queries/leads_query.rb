class LeadsQuery
  def initialize(options)
    @options = options
    @relation = default_relation.extending(Scopes)
  end

  def perform
    relation
      .by_relation(options)
      .by_status(options[:status])
      .by_search(options[:search])
      .by_id(options[:search])
      .includes(:contact, :user, :company, :client, :deals)
  end

  private

  attr_reader :options, :relation

  def default_relation
    Lead.by_company_id options[:user].company.id
  end

  module Scopes
    def by_status(status)
      return self unless status

      case status
      when 'new_leads'
        new_records
      when 'accepted'
        accepted
      when 'rejected'
        rejected
      end
    end

    def by_relation(options)
      return self unless options[:relation]

      case options[:relation]
      when 'my'
        by_user options[:user].id
      when 'team'
        by_team options[:user]
      when 'all'
        self
      end
    end

    def by_user(user_id)
      where(user_id: user_id)
    end

    def by_team(user)
      user.leader? ? by_leader(user) : by_user(user.team.user_ids)
    end

    def by_leader(user)
      by_user(Team.find_by(leader_id: user.id).member_ids << user.id)
    end

    def by_search(search)
      return self if search.nil? || !search.to_i.zero?

      where(
        'first_name ilike :search OR
         last_name ilike :search OR
         company_name ilike :search',
        search: "%#{search}%"
      )
    end

    def by_id(search)
      return self if search.nil? || search.to_i.zero?

      where(id: search.to_i)
    end
  end
end
