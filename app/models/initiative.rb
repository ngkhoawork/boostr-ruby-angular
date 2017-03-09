class Initiative < ActiveRecord::Base
  OPEN = 'open'.freeze
  CLOSED = 'closed'.freeze
  STATUSES = [OPEN, CLOSED]

  has_many :deals
  belongs_to :company

  validates :name, :goal, :status, :company_id, presence: true
  validates :status, inclusion: { in: STATUSES }
end
