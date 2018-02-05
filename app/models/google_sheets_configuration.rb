class GoogleSheetsConfiguration < ApiConfiguration
  has_one :google_sheets_details, foreign_key: :api_configuration_id, dependent: :destroy

  accepts_nested_attributes_for :google_sheets_details

  delegate :sheet_id, to: :google_sheets_details, prefix: false
end
