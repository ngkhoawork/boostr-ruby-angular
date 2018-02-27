class SalesProcess < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :stages
  has_many :teams

  validates :name, presence: true, uniqueness: { scope: :company }

  scope :is_active, -> (status) { where(active: status) unless status.nil? }
end
