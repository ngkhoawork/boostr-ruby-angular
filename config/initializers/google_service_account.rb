require 'google/apis/sheets_v4'

SERVICE_ACCOUNT_EMAIL = Google::Auth::DefaultCredentials.make_creds(
  scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS,
  json_key_io: StringIO.new(ENV['GOOGLE_SHEETS_CREDENTIALS'])
).issuer
SERVICE_ACCOUNT_EMAIL.freeze
