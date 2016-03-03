class Team < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent, class_name: 'Team', inverse_of: :children
  has_many :children, class_name: 'Team', foreign_key: 'parent_id', inverse_of: :parent
  has_many :members, -> (team) { where(company_id: team.company_id) }, class_name: 'User', dependent: :nullify
  belongs_to :leader, class_name: 'User', foreign_key: :leader_id
  has_many :deals, through: :members
  has_many :clients, through: :members

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

  def sum_pos_balance
    pos_balance = members.all.sum(:pos_balance)
    children.each do |child|
      pos_balance += child.sum_pos_balance
    end
    return pos_balance
  end

  def sum_neg_balance
    neg_balance = members.all.sum(:neg_balance)
    children.each do |child|
      neg_balance += child.sum_neg_balance
    end
    return neg_balance
  end
end
