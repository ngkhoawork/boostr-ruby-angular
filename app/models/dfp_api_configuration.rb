class DfpApiConfiguration < ApiConfiguration
  serialize :json_api_key, JSON

  validates :json_api_key, presence: true
  attr_encrypted :json_api_key, key: Rails.application.secrets.secret_key_base, marshal: true

  has_many :dfp_report_queries, foreign_key: :api_configuration_id, dependent: :destroy
  has_one :cpm_budget_adjustment, foreign_key: :api_configuration_id, dependent: :destroy

  accepts_nested_attributes_for :cpm_budget_adjustment
  accepts_nested_attributes_for :dfp_report_queries

  delegate :percentage, to: :cpm_budget_adjustment, prefix: true

end
