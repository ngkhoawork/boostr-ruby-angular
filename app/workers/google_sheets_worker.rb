class GoogleSheetsWorker < BaseWorker
  def perform(sheet_id, deal_id)
    deal = Deal.find(deal_id)

    GoogleSheetsApiClient.perform(sheet_id, deal)
  end
end
