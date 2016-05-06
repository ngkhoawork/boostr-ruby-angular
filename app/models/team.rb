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

  def as_json(options = {})
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
    ))
  end

  def leader_name
    leader.name if leader.present?
  end

  def all_deals_for_time_period(start_date, end_date)
    deals.open.for_time_period(start_date, end_date) + children.map {|c| c.all_deals_for_time_period(start_date, end_date) }
  end

  def all_revenues_for_time_period(start_date, end_date)
    rs = revenues.for_time_period(start_date, end_date) + children.map {|c| c.all_revenues_for_time_period(start_date, end_date)}
    rs.flatten.map {|r| r.set_period_budget(start_date, end_date)}
    return rs
  end

  def all_members
    ms = []
    ms += members.all
    children.each do |child|
      ms += child.all_members
    end
    return ms
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
end
