require 'rails_helper'

describe DealTotalBudgetUpdaterService do
  describe '#perform' do
    let(:company) { create :company }
    let!(:deal) { create :deal, company: company }
    let!(:deal_product) { create :deal_product, deal: deal, budget: 1000 }

    context '#call' do
      before { described_class.perform(deal) }

      it 'updates deal budget' do
        expect(deal.budget).to eq(deal_product.budget)
      end
    end
  end

  private

  def google_sheet_id
    @_google_sheet_id ||= deal.company.google_sheets_configurations.first&.sheet_id
  end
end
