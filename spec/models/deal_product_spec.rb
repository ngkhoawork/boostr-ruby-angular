require 'rails_helper'

RSpec.describe DealProduct, type: :model do
  let!(:product) { create :product }
  let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29) }
  let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 1_000 }

  describe '#update_budget' do
    it 'sets the budget to the sum of deal product budgets' do
      expect(deal_product.budget).to eq(100000)
      deal_product_budget = deal_product.deal_product_budgets.first
      deal_product_budget.update(budget: 5000)
      deal_product.update_budget
      expect(deal_product.budget).to eq(deal_product.deal_product_budgets.sum(:budget))
    end
  end

  describe '#create_product_budgets' do
    it 'creates product budgets for the time period' do
      deal_product = create :deal_product, deal: deal, product: product, budget: 1_000
      deal_product_budgets = deal_product.deal_product_budgets
      expect(deal_product_budgets.count).to eq(2)
      expect(deal_product_budgets.map(&:start_date)).to eq([Date.new(2015, 7, 1), Date.new(2015, 8, 1)])
      expect(deal_product_budgets.map(&:end_date)).to eq([Date.new(2015, 7, 31), Date.new(2015, 8, 31)])
      expect(deal_product_budgets.map(&:budget)).to eq([9400, 90600])
    end
  end

  describe '#update_product_budgets' do
    it 'splits total budget over month and updates product budgets' do
      deal_product.update(budget: 90_000)
      deal_product.update_product_budgets
      deal_product_budgets = deal_product.deal_product_budgets
      expect(deal_product_budgets.count).to eq(2)
      expect(deal_product_budgets.map(&:budget)).to eq([843800, 8156200])
    end
  end

  describe '#daily_budget' do
    it 'returns daily budget based on the deal start and end dates' do
      expect(deal_product.daily_budget).to eq(deal_product.budget / 100.0 / deal.days)
    end
  end

  context 'before_update' do
    it 'multiplies budget by 100' do
      deal_product.update(budget: 8888)
      expect(deal_product.budget).to eq(888_800)
    end
  end

  context 'before_create' do
    it 'multiplies budget by 100' do
      deal_product = create :deal_product, deal: deal, product: product, budget: 1_000
      expect(deal_product.budget).to eq(100_000)
    end
  end

  context 'after_update' do
    let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29) }
    let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 1_000 }

    it 'updates total deal budget' do
      deal_product.update(budget: 8888)
      expect(deal_product.deal.budget).to eq(888_800)
    end

    context 'when sum of deal product budgets is not equal to the total budget' do
      it 'updates deal products if budget was updated' do
        deal_product.update(budget: 8888)
        expect(deal_product.deal_product_budgets.sum(:budget)).to eq(888_800)
      end

      it 'updates total budget if budget was not updated' do
        deap_product_budget = deal_product.deal_product_budgets.first
        deal_product.update(deal_product_budgets_attributes: {id: deap_product_budget.id, budget: 90_000})
        expect(deal_product.budget).to eq(deal_product.deal_product_budgets.sum(:budget))
      end
    end

    context 'when sum of deal product budgets is equal to the total budget' do
      it 'does not modify total budget or product budgets' do
        deap_product_budget = deal_product.deal_product_budgets.first
        deal_product.update(deal_product_budgets_attributes: {id: deap_product_budget.id, budget: 95_000})
        expect(deal_product.budget).to eq(9590600)
        expect(deal_product.deal_product_budgets.sum(:budget)).to eq(9590600)
      end
    end
  end
end
