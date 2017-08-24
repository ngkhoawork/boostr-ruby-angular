class ActivityType < ActiveRecord::Base
  has_many :activities
  belongs_to :company

  validates :company_id, :name, :position, :action, presence: true

  scope :ordered_by_position, -> { order(:position) }
  scope :by_name, -> (name) { where(name: name) }
  scope :active, -> { where(active: true) }
end
