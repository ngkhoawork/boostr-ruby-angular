class Team < ActiveRecord::Base
  belongs_to :company
  has_many :children, class_name: 'Team', foreign_key: 'parent_id', inverse_of: :parent
  belongs_to :parent, class_name: 'Team', inverse_of: :children

  scope :roots, -> { where parent_id: nil }

  validates :name, presence: true

  def as_json(options = {})
    super(options.merge(include: [:children, :parent]))
  end
end
