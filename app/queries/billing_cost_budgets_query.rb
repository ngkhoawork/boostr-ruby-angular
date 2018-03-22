class BillingCostBudgetsQuery < BaseQuery
  def perform
    default_relation
      .join_costs
      .join_ios
      .join_io_members
      .join_users
      .by_company_id(options[:company_id])
      .by_member_ids(member_ids)
      .by_year_month(date)
      .distinct
  end

  private

  def default_relation
    CostMonthlyAmount
      .all
      .includes(
        cost: {
          product: {},
          io: {
            currency: {}
          },
          values: :option
        }
      )
      .extending(Scopes)
  end

  def user
    User.find_by(id: options[:user_id])
  end

  def manager
    User.find_by(id: options[:manager_id])
  end

  def team
    Team.find_by(id: options[:team_id])
  end

  def member_ids
    member_ids = []
    member_ids += user_ids if user_ids
    member_ids += manager_ids if manager_ids
    if member_ids.count > 0
      member_ids.uniq
    else
      nil
    end
  end

  def user_ids
    if user
      [user.id]
    else
      teams.map(&:all_sales_reps).flatten.map(&:id)
    end
  end

  def manager_ids
    if manager
      [manager.id]
    else
      teams.map(&:all_account_managers).flatten.map(&:id)
    end
  end

  def teams
    if team
      [team]
    else
      root_teams
    end
  end

  def root_teams
    company.teams.roots(true)
  end

  def company
    Company.find_by(id: options[:company_id])
  end

  def date
    @_date ||= [options[:year], options[:month]].join(' ').to_date
  end

  def start_date
    @_start_date ||= date.beginning_of_month
  end

  def end_date
    @_end_date ||= date.end_of_month
  end

  module Scopes
    def by_company_id(company_id)
      if company_id
        where('ios.company_id = ?', company_id)
      else
        self
      end
    end

    def by_year_month(date)
      where("DATE_PART('year', cost_monthly_amounts.start_date) = ? AND DATE_PART('month', cost_monthly_amounts.start_date) = ?", date.year, date.month)
    end

    def join_costs
      joins('INNER JOIN costs ON cost_monthly_amounts.cost_id = costs.id')
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
  end
end
