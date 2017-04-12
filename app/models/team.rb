class Team < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent, class_name: 'Team', inverse_of: :children
  has_many :children, class_name: 'Team', foreign_key: 'parent_id', inverse_of: :parent
  has_many :members, -> (team) { where(company_id: team.company_id) }, class_name: 'User', dependent: :nullify
  belongs_to :leader, class_name: 'User', foreign_key: :leader_id
  has_many :deals, through: :members
  has_many :clients, through: :members
  has_many :revenues, through: :clients

  scope :roots, proc {|root_only|
    where(parent_id: nil) if root_only
  }

  validates :name, presence: true

  before_destroy do
    remove_team_leader
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.merge(
        only: [:id, :members_count, :name, :parent_id, :leader_id],
        include: {
          children: {
            only: [:id, :members_count, :name, :parent_id],
            methods: [:leader_name],
            include: [
              members: {
                only: [:id, :first_name, :last_name]
              },
              leader: {
                only: [:id, :first_name, :last_name]
              }
            ]
          },
          members: {
            only: [:id, :first_name, :last_name, :team_id]
          },
          parent: { only: [:id, :name] } },
        methods: [:leader_name]
      ).except(:override))
    end
  end

  def all_children
    temp_children = Team.where(parent_id: self.id)
    children = []
    temp_children.each do |child|
      temp_child = child.as_json
      temp_child[:children] = child.all_children
      temp_child[:members] = child.all_members
      temp_child[:leaders] = child.all_leaders
      temp_child[:members_count] = temp_child[:members].count
      children << temp_child
    end
    children
  end

  def remove_team_leader
    self.update(leader_id: nil)
  end
  # def all_members(children_array = [])
  #   children = Team.where(parent_id: self.id)
  #   children_array += self.members
  #   children.each do |child|
  #     child.all_members(children_array)
  #   end
  #   children_array
  # end

  def leader_name
    leader.name if leader.present?
  end

  def all_deals_for_time_period(start_date, end_date)
    deals.where(open: true).for_time_period(start_date, end_date) + children.map {|c| c.all_deals_for_time_period(start_date, end_date) } + (leader.nil? ? [] : leader.all_deals_for_time_period(start_date, end_date))
  end

  def all_revenues_for_time_period(start_date, end_date)
    rs = revenues.for_time_period(start_date, end_date) + children.map {|c| c.all_revenues_for_time_period(start_date, end_date)}
    rs.flatten.map {|r| r.set_period_budget(start_date, end_date)}
    return rs
  end

  def crevenues(start_date, end_date)
    ios = all_members.map { |user| user.all_ios_for_time_period(start_date, end_date)  }.flatten.uniq

    @crevenues ||= ios.each_with_object([]) do |io, memo|
      sum_period_budget, split_period_budget = io.for_forecast_page(start_date, end_date)

      memo << {
        id: io.id,
        name: io.name,
        agency: io.get_agency,
        advertiser: io.advertiser.name,
        budget: io.budget.to_s,
        sum_period_budget: sum_period_budget,
        split_period_budget: split_period_budget
      }
    end
  end

  def quarterly_ios(start_date, end_date)
    ios = all_members.map { |user| user.all_ios_for_time_period(start_date, end_date)  }.flatten.uniq.as_json
    members_id = all_members.map{ |user| user.id }
    year = start_date.year
    ios.map do |io|
      io_obj = Io.find(io['id'])
      start_month = start_date.month
      end_month = end_date.month
      io[:quarters] = Array.new(4, nil)
      io[:months] = Array.new(12, nil)
      for i in start_month..end_month
        io[:months][i - 1] = 0
      end
      for i in ((start_month - 1) / 3)..((end_month - 1) / 3)
        io[:quarters][i] = 0
      end
      total = 0
      io[:members] = io_obj.io_members
      share = io_obj.io_members.where("user_id in (?)", members_id).pluck(:share).sum

      if io['end_date'] == io['start_date']
        io['end_date'] += 1.day
      end

      io_obj.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
        month = content_fee_product_budget.start_date.mon
        io[:months][month - 1] += content_fee_product_budget.budget
        io[:quarters][(month - 1) / 3] += content_fee_product_budget.budget
        total += content_fee_product_budget.budget
      end

      io_obj.display_line_items.for_time_period(start_date, end_date).each do |display_line_item|
        display_line_item_budgets = display_line_item.display_line_item_budgets.to_a

        for index in start_date.mon..end_date.mon
          month = index.to_s
          if index < 10
            month = '0' + index.to_s
          end
          first_date = Date.parse("#{year}#{month}01")

          num_of_days = [[first_date.end_of_month, display_line_item.end_date].min - [first_date, display_line_item.start_date].max + 1, 0].max.to_f
          in_budget_days = 0
          in_budget_total = 0
          display_line_item_budgets.each do |display_line_item_budget|
            in_from = [first_date, display_line_item.start_date, display_line_item_budget.start_date].max
            in_to = [first_date.end_of_month, display_line_item.end_date, display_line_item_budget.end_date].min
            in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
            in_budget_days += in_days
            in_budget_total += display_line_item_budget.daily_budget * in_days
          end
          budget = in_budget_total + display_line_item.ave_run_rate * (num_of_days - in_budget_days)
          io[:months][index - 1] += budget
          io[:quarters][(index - 1) / 3] += budget
          total += budget
        end
      end

      io['in_period_amt'] = total
      io['in_period_split_amt'] = total * share / 100
    end

    ios
  end

  def all_members
    ms = []
    ms += members.all
    children.find_each do |child|
      ms += child.all_members
    end
    ms
  end

  def all_sellers
    sellers = []
    sellers += members.by_user_type(SELLER)
    children.each do |child|
      sellers += child.all_sellers
    end
    sellers
  end

  def all_sales_reps
    sales_reps = []
    sales_reps << leader if !leader.nil?
    sales_reps += members.by_user_type([SELLER, SALES_MANAGER])
    children.each do |child|
      sales_reps += child.all_sales_reps
    end
    sales_reps
  end

  def all_leaders
    ls = leader.nil? ? []:[leader]
    children.find_each do |child|
      ls << child.leader if !child.leader.nil?
    end
    ls
  end

  def sum_pos_balance
    pos_balance = leader.nil? ? 0 : leader.pos_balance
    pos_balance += members.all.sum(:pos_balance)
    children.each do |child|
      pos_balance += child.sum_pos_balance
    end
    return pos_balance
  end

  def sum_neg_balance
    neg_balance = leader.nil? ? 0 : leader.neg_balance
    neg_balance += members.all.sum(:neg_balance)
    children.each do |child|
      neg_balance += child.sum_neg_balance
    end
    return neg_balance
  end

  def sum_pos_balance_lcnt
    pos_balance_lcnt = leader.nil? ? 0 : leader.pos_balance_lcnt
    pos_balance_lcnt += members.all.sum(:pos_balance_lcnt)
    children.each do |child|
      pos_balance_lcnt += child.sum_pos_balance_lcnt
    end
    return pos_balance_lcnt
  end

  def sum_neg_balance_lcnt
    neg_balance_lcnt = leader.nil? ? 0 : leader.neg_balance_lcnt
    neg_balance_lcnt += members.all.sum(:neg_balance_lcnt)
    children.each do |child|
      neg_balance_lcnt += child.sum_neg_balance_lcnt
    end
    return neg_balance_lcnt
  end

  def descendents
    self.class.descendents_for(self)
  end

  def self.descendents_for(instance)
    where("teams.id IN (#{descendents_sql(instance)})")
  end

  def self.descendents_sql(instance)
    sql = <<-SQL
      WITH RECURSIVE team_tree(id, path) AS (
          SELECT teams.id, ARRAY[teams.id]
          FROM teams
          WHERE teams.id = #{instance.id}
        UNION ALL
          SELECT teams.id, path || teams.id
          FROM team_tree
          JOIN teams ON teams.parent_id = team_tree.id
          WHERE NOT teams.id = ANY(path)
      )
      SELECT id FROM team_tree ORDER BY path
    SQL
  end
end
