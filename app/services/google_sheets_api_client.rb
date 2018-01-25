require 'google/apis/sheets_v4'
require 'googleauth/stores/file_token_store'

class GoogleSheetsApiClient
  class RecordNotFoundInSpreadsheet < StandardError; end
  class RecordAlreadyExistsInSpreadsheet < StandardError; end
  class RecordNotSaved < StandardError; end

  APPLICATION_NAME = 'Boostrcrm'.freeze
  SCOPE            = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  ID_COLUMN_RANGE  = 'A:A'.freeze
  DEFAULT_RANGE    = 'A:AP'.freeze

  delegate :append_spreadsheet_value, :update_spreadsheet_value, :get_spreadsheet_values, to: :service
  delegate :id, to: :record

  attr_reader :service, :spreadsheet_id, :values, :record

  def self.add_row(spreadsheet_id, record)
    new(spreadsheet_id, record).add_row
  end

  def self.update_row(spreadsheet_id, record)
    new(spreadsheet_id, record).update_row
  end

  def initialize(spreadsheet_id, record)
    raise RecordNotSaved if record.id.nil?

    @service = Google::Apis::SheetsV4::SheetsService.new
    @spreadsheet_id = spreadsheet_id
    @values = GoogleSpreadsheets::DealSerializer.new(record).to_spreadsheet
    @record = record

    authorize_service
  end

  def add_row
    raise RecordAlreadyExistsInSpreadsheet if row_record_index.present?

    response = append_spreadsheet_value(spreadsheet_id, DEFAULT_RANGE, values, value_input_option: :raw)

    response&.updates&.updated_rows == 1
  end

  def update_row
    raise RecordNotFoundInSpreadsheet if row_record_index.nil?

    response = update_spreadsheet_value(spreadsheet_id, range, values, value_input_option: :raw)

    response&.updated_rows == 1
  end

  private

  def range
    "A#{row_record_index}:AP#{row_record_index}"
  end

  def row_record_index
    return @_row_record_index if defined? @_row_record_index

    index = get_spreadsheet_values(spreadsheet_id, ID_COLUMN_RANGE).values.index([id.to_s])

    return nil unless index

    @_row_record_index ||= index + 1
  end

  def authorize_service
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = Google::Auth.get_application_default(SCOPE)
  end
end
