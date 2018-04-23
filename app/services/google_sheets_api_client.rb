require 'google/apis/sheets_v4'
require 'googleauth/stores/file_token_store'

class GoogleSheetsApiClient
  class RecordNotSaved < StandardError; end

  APPLICATION_NAME = 'Boostrcrm'.freeze
  SCOPE            = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  ID_COLUMN_RANGE  = 'A:A'.freeze
  DEFAULT_RANGE    = 'A:AT'.freeze

  delegate :append_spreadsheet_value, :update_spreadsheet_value, :get_spreadsheet_values, to: :service
  delegate :id, to: :record

  attr_reader :service, :spreadsheet_id, :values, :record

  def self.perform(*args)
    new(*args).perform
  end

  def initialize(spreadsheet_id, record)
    raise RecordNotSaved if record.id.nil?

    @service = Google::Apis::SheetsV4::SheetsService.new
    @spreadsheet_id = spreadsheet_id
    @values = GoogleSpreadsheets::DealSerializer.new(record).to_spreadsheet
    @record = record

    authorize_service
  end

  def perform
    updated_rows = if row_record_index
                     update_spreadsheet_value(*args)&.updated_rows
                   else
                     append_spreadsheet_value(*args)&.updates&.updated_rows
                   end

    updated_rows.eql?(1)
  end

  private

  def args
    [spreadsheet_id, range, values, value_input_option: :raw]
  end

  def range
    return DEFAULT_RANGE unless row_record_index

    "A#{row_record_index}:AT#{row_record_index}"
  end

  def row_record_index
    return @_row_record_index if defined? @_row_record_index

    index = get_spreadsheet_values(spreadsheet_id, ID_COLUMN_RANGE).values.index([id.to_s])

    @_row_record_index = index ? index + 1 : nil
  end

  def authorize_service
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = Google::Auth::DefaultCredentials.make_creds(
      scope: SCOPE,
      json_key_io: StringIO.new(ENV['GOOGLE_SHEETS_CREDENTIALS'])
    )
  end
end
