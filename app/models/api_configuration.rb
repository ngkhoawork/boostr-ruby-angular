class ApiConfiguration < ActiveRecord::Base
  self.inheritance_column = :integration_type

  INTEGRATION_PROVIDERS = ['google', 'operative', 'Operative Datafeed']

  belongs_to :company

  validates :company_id, presence: true

end
