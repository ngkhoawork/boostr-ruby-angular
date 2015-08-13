require 'rails_helper'

RSpec.describe Deal, type: :model do

  describe '#days' do
    let(:deal) { create :deal, start_date: Date.new(2015, 1, 1), end_date: Date.new(2015, 2, 1) }

    it 'returns the number of days between the start and end dates.' do
      expect(deal.days).to eq(31)
    end
  end

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)}

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#add_product' do
    let(:product) { create :product }

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expected_budgets = [500000, 3100000, 3000000, 2800000]
      expect{
        deal.add_product(product, "94000")
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(9_400_000)
      }.to change(DealProduct, :count).by(4)
    end

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)

      expected_budgets = [3478261, 6521739]
      expect{
        deal.add_product(product, "100000")
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(10_000_000)
      }.to change(DealProduct, :count).by(2)
    end
  end

  describe '#days_per_month' do
    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expect(deal.days_per_month).to eq([5, 31, 30, 28])
    end

    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([16, 30])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([5])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 10, 15)
      expect(deal.days_per_month).to eq([5, 15])
    end
  end
end