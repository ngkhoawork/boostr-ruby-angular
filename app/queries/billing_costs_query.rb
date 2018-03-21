class BillingCostsQuery < BaseQuery
  def perform
    default_relation
      .join_ios
      .join_io_members
      .join_users
      .by_company_id(options[:company_id])
      .by_member_ids(member_ids)
      .by_user_type(options[:user_type])
      .distinct
  end

  private

  def default_relation
    Cost
      .all
      .includes(
        :product,
        io: {
          currency: {}
        },
        values: :option
      )
      .extending(Scopes)
  end

  def member
    User.find_by(id: options[:user_id])
  end

  def team
    Team.find_by(id: options[:team_id])
  end

  def member_ids
    if member
      [member.id]
    elsif team
      team.all_members_and_leaders
    end
  end

  module Scopes
    def by_company_id(company_id)
      if company_id
        where('ios.company_id = ?', company_id)
      else
        self
      end
    end

    def join_ios
      joins('INNER JOIN ios ON ios.id = costs.io_id')
    end

    def join_io_members
      joins('INNER JOIN io_members ON ios.id = io_members.io_id')
    end

    def join_users
      joins('INNER JOIN users ON users.id = io_members.user_id')
    end

    def by_member_ids(member_ids)
      if member_ids
        # self
        where(io_members: { user_id: member_ids })
      else
        self
      end
    end

    def by_user_type(user_type)
      if user_type
        where(users: { user_type: user_type })
      else
        self
      end
    end
  end
end
