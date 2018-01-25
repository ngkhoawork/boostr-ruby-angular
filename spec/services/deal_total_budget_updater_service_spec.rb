require 'rails_helper'

describe DealTotalBudgetUpdaterService do
  describe '#perform' do
    let(:company) { create :company }
    let!(:deal) { create :deal, company: company }
    let!(:deal_product) { create :deal_product, deal: deal, budget: 1000 }

    context 'if called' do
      before { described_class.perform(deal) }

      it 'updates deal budget' do
        expect(deal.budget).to eq(deal_product.budget)
      end
    end

    context 'if Google Sheets integration enabled' do
      let(:google_sheets_configuration) { create :google_sheets_configuration, company: company }
      let!(:google_sheets_details) { create :google_sheets_details, api_configuration: google_sheets_configuration }

      it 'calls GoogleSheetsWorker' do
        expect(GoogleSheetsWorker).to receive(:perform_async).with(google_sheet_id, deal.id)
        described_class.perform(deal)
      end
    end
  end

  private

  def google_sheet_id
    @_google_sheet_id ||= deal.company.google_sheets_configurations.first&.sheet_id
  end
end
