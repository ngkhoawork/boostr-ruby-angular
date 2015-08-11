require 'rails_helper'

RSpec.describe Deal, type: :model do

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)}

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#add_product' do
    let(:deal) { create :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28) }
    let(:product) { create :product }

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      expect{
        deal.add_product(product, "10000")
        expect(DealProduct.first.budget).to eq(2500)
      }.to change(DealProduct, :count).by(4)
    end
  end
end