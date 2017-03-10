class Initiative < ActiveRecord::Base
  STATUSES = %w('Open open Closed closed')

  has_many :deals
  belongs_to :company

  validates :name, :goal, :status, :company_id, presence: true
  validates :status, inclusion: { in: STATUSES }
end
