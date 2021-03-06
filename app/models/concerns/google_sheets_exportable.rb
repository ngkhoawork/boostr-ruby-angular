module GoogleSheetsExportable
  extend ActiveSupport::Concern

  included do
    after_commit :schedule_google_sheets_export
  end

  def schedule_google_sheets_export
    return if legacy_id
    return unless manual_update
    return unless (config = company.google_sheets_configurations.first)

    GoogleSheetsWorker.perform_async(config.sheet_id, id) if config.switched_on?
  end
end
