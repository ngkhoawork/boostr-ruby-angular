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
    deals.where(open: true).for_time_period(start_date, end_date) + children.map {|c| c.all_deals_for_time_period(start_date, end_date) } + leader.all_deals_for_time_period(start_date, end_date)
  end

  def all_revenues_for_time_period(start_date, end_date)
    rs = revenues.for_time_period(start_date, end_date) + children.map {|c| c.all_revenues_for_time_period(start_date, end_date)}
    rs.flatten.map {|r| r.set_period_budget(start_date, end_date)}
    return rs
  end

  def crevenues(start_date, end_date)
    return @crevenues if defined?(@crevenues)
    @crevenues = []
    all_members.each do |member|
      @crevenues += member.crevenues(start_date, end_date)
    end
    @crevenues
  end

  def all_members
    ms = []
    ms += members.all
    children.each do |child|
      ms += child.all_members
    end
    return ms
  end

  def all_sellers
    sellers = []
    sellers += members.by_user_type(SELLER)
    children.each do |child|
      sellers += child.all_sellers
    end
    sellers
  end


  def all_leaders
    ls = leader.nil? ? []:[leader]
    children.each do |child|
      ls << child.leader if !child.leader.nil?
    end
    return ls
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
