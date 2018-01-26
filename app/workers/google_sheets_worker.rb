class GoogleSheetsWorker < BaseWorker
  def perform(sheet_id, deal_id)
    deal = Deal.find(deal_id)

    if deal.updated?
      GoogleSheetsApiClient.update_row(sheet_id, deal)
    else
      GoogleSheetsApiClient.add_row(sheet_id, deal)
    end
  end
end
