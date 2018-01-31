module Concerns
  module GoogleSheetsDealExportable
    extend ActiveSupport::Concern

    private

    def schedule_google_sheets_export
      GoogleSheetsWorker.perform_async(google_sheet_id, deal.id) if google_sheet_id
    end

    def google_sheet_id
      @_google_sheet_id ||= deal.company.google_sheets_configurations.first&.sheet_id
    end
  end
end
