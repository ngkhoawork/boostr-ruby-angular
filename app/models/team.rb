class Team < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent, class_name: 'Team', inverse_of: :children
  has_many :children, class_name: 'Team', foreign_key: 'parent_id', inverse_of: :parent
  has_many :members, class_name: 'User', dependent: :nullify
  belongs_to :leader, class_name: 'User', foreign_key: :leader_id

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
    leader.full_name if leader.present?
  end
end
