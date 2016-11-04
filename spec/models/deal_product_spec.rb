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

  describe '#import' do
    let!(:user) { create :user }
    let!(:company) { user.company }
    let!(:product) { create :product }
    let!(:existing_deal) { create :deal }
    let!(:three_month_deal) { create :deal, start_date: Date.new(2015, 7), end_date: Date.new(2015, 9).end_of_month }
    let!(:deal_with_product) { create :deal }
    let!(:existing_deal_product) { create :deal_product, deal: deal_with_product, product: product, budget: 1_000 }

    it 'creates new deal product' do
      data = build :deal_product_csv_data, deal_name: three_month_deal.name
      expect do
        expect(DealProduct.import(generate_csv(data), user)).to eq([])
      end.to change(DealProduct, :count).by(1)

      deal_product = DealProduct.last
      expect(deal_product.budget).to eq(data[:budget] * 100)
      expect(deal_product.product.name).to eq(data[:product])
      expect(deal_product.deal_product_budgets.count).to eq 3
      expect(deal_product.deal_product_budgets.sum(:budget)).to eq(data[:budget] * 100)
      expect(deal_product.deal.budget).to eq(data[:budget] * 100)
    end

    it 'updates existing deal product' do
      data = build :deal_product_csv_data, deal_id: deal_with_product.id, product: product.name, budget: 50_000
      expect do
        expect(DealProduct.import(generate_csv(data), user)).to eq([])
      end.not_to change(DealProduct, :count)

      deal_with_product.reload
      existing_deal_product.reload

      expect(deal_with_product.deal_products.count).to be 1
      expect(deal_with_product.budget).to be (data[:budget] * 100)
      expect(existing_deal_product.budget).to be (data[:budget] * 100)
      expect(existing_deal_product.deal_product_budgets.count).to be 2
    end

    context 'invalid data' do
      let!(:duplicate_deal) { create :deal, name: FFaker::NatoAlphabet.callsign }
      let!(:duplicate_deal2) { create :deal, name: duplicate_deal.name }

      it 'requires deal ID to match' do
        data = build :deal_product_csv_data, deal_id: 0
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal ID #{data[:deal_id]} could not be found"]])
      end

      it 'requires deal name to be present' do
        data = build :deal_product_csv_data
        data[:deal_name] = nil
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name can't be blank"]])
      end

      it 'requires deal name to match only 1 record' do
        data = build :deal_product_csv_data, deal_name: duplicate_deal.name
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name #{data[:deal_name]} matched more than one deal record"]])
      end

      it 'requires deal name to match at least one record' do
        data = build :deal_product_csv_data, deal_name: 'N/A'
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name #{data[:deal_name]} did not match any Deal record"]])
      end

      it 'requires product to be present' do
        data = build :deal_product_csv_data
        data[:product] = nil
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Product can't be blank"]])
      end

      it 'requires product to exist' do
        data = build :deal_product_csv_data, product: 'N/A'
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Product #{data[:product]} could not be found"]])
      end

      it 'requires budget to be present' do
        data = build :deal_product_csv_data
        data[:budget] = nil
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Budget can't be blank"]])
      end

      it 'validates numericality of budget' do
        data = build :deal_product_csv_data, budget: 'test'
        expect(
          DealProduct.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Budget must be a numeric value"]])
      end
    end
  end
end
