class Initiative < ActiveRecord::Base
  OPEN = 'Open'.freeze
  CLOSED = 'Closed'.freeze
  STATUSES = [OPEN, CLOSED]

  has_many :deals
  belongs_to :company

  validates :name, :goal, :status, :company_id, presence: true
  validates :status, inclusion: { in: STATUSES }
end
