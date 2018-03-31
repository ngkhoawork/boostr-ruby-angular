class ApiConfiguration < ActiveRecord::Base
  self.inheritance_column = :integration_type

  INTEGRATION_PROVIDERS = {
    'DFP': 'DfpApiConfiguration',
    'operative': 'OperativeApiConfiguration',
    'Operative Datafeed': 'OperativeDatafeedConfiguration',
    'Asana Connect': 'AsanaConnectConfiguration',
    'Google Sheets': 'GoogleSheetsConfiguration',
    'SSP': 'SspCredential'
  }

  belongs_to :company

  validates :company_id, presence: true

  scope :switched_on, -> { where(switched_on: true) }

  def self.metadata(routing_param)
    klass = self::INTEGRATION_PROVIDERS[routing_param.to_sym]
    klass.constantize.metadata
  end
end
