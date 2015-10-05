class Stage < ActiveRecord::Base
  belongs_to :company
  has_many :deals

  default_scope { order(:position) }
  scope :active, -> { where(active: true) }

  validates :name, presence: true
end
