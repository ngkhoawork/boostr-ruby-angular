class ApiConfiguration < ActiveRecord::Base
  self.inheritance_column = :integration_type

  INTEGRATION_PROVIDERS = { dfp: 'google', operative: 'operative', operative_datafeed: 'operative datafeed' }

  belongs_to :company

  validates :company_id, presence: true

  scope :switched_on, -> { where(switched_on: true) }

end