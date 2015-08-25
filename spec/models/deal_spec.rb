require 'rails_helper'

RSpec.describe Deal, type: :model do
  context 'scopes' do
    context 'for_client' do
      let!(:company) { create :company }
      let!(:deal) { create :deal, company: company }
      let(:agency) { create :agency, company: company }
      let!(:another_deal) { create :deal, company: company, agency: agency }

      it 'returns all when client_id is nil' do
        expect(Deal.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Deal.for_client(agency.id).count).to eq(1)
      end
    end
  end

  describe '#days' do
    let(:deal) { create :deal, start_date: Date.new(2015, 1, 1), end_date: Date.new(2015, 1, 31) }

    it 'returns the number of days between the start and end dates.' do
      expect(deal.days).to eq(31)
    end
  end

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28) }

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#add_product' do
    let(:product) { create :product }

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expected_budgets = [600_000, 3_100_000, 3_000_000, 2_800_000]
      expect do
        deal.add_product(product, '95000')
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(9_500_000)
      end.to change(DealProduct, :count).by(4)
    end

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)

      expected_budgets = [3_617_021, 6_382_979]
      expect do
        deal.add_product(product, '100000')
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(10_000_000)
      end.to change(DealProduct, :count).by(2)
    end
  end

  describe '#days_per_month' do
    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expect(deal.days_per_month).to eq([6, 31, 30, 28])
    end

    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([17, 30])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([6])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 10, 15)
      expect(deal.days_per_month).to eq([6, 15])
    end
  end
end
