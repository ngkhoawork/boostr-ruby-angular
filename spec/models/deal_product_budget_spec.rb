require 'rails_helper'

RSpec.describe DealProductBudget, type: :model do
  context 'scopes' do
    let(:company) { create :company }

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', company: company }
      let!(:in_deal_product) { create :deal_product_budget, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal_product) { create :deal_product_budget, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'returns deals that are completely in the time period' do
        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date)).to include(in_deal_product)
      end

      it 'returns deals that are partially in the time period' do
        create :deal_product_budget, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal_product_budget, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end
  end

  describe '#import' do
    let!(:user) { create :user }
    let!(:company) { user.company }
    let!(:product) { create :product }
    let!(:existing_deal) { create :deal }
    let!(:three_month_deal) { create :deal, start_date: Date.new(2015, 7), end_date: Date.new(2015, 9).end_of_month }

    it 'creates new deal product' do
      data = build :deal_product_budget_csv_data
      expect do
        expect(DealProductBudget.import(generate_csv(data), user)).to eq([])
      end.to change(DealProduct, :count).by(1)

      deal_product = DealProduct.last
      expect(deal_product.budget).to eq(data[:budget])
    end

    it 'creates new deal product budget' do
      data = build :deal_product_budget_csv_data
      expect do
        expect(DealProductBudget.import(generate_csv(data), user)).to eq([])
      end.to change(DealProductBudget, :count).by(1)
    end

    it "updates deal product's budget" do
      data = build :deal_product_budget_csv_data
      expect(DealProductBudget.import(generate_csv(data), user)).to eq([])
      deal_product = DealProduct.last
      expect(deal_product.budget).to eq(data[:budget])
    end

    it "updates deal's total budget" do
      data = build :deal_product_budget_csv_data
      expect(DealProductBudget.import(generate_csv(data), user)).to eq([])
      deal_product = DealProduct.last
      expect(deal_product.deal.budget).to eq(deal_product.budget)
    end

    it 'generates three deal product budgets for three month deal' do
      row1 = build :deal_product_budget_csv_data, deal_id: three_month_deal.id
      row2 = build :deal_product_budget_csv_data, deal_id: three_month_deal.id, period: 'Aug-15'
      row3 = build :deal_product_budget_csv_data, deal_id: three_month_deal.id, period: 'Sep-15'

      expect do
        expect(DealProductBudget.import(generate_csv(row1), user)).to eq([])
        expect(DealProductBudget.import(generate_csv(row2), user)).to eq([])
        expect(DealProductBudget.import(generate_csv(row3), user)).to eq([])
      end.to change(DealProductBudget, :count).by(3)
      three_month_deal.reload

      deal_product = three_month_deal.deal_products.first
      expect(deal_product.budget).to eq(30000)
      expect(three_month_deal.budget).to eq(30000)
      expect(deal_product.deal_product_budgets.count).to eq(3)
    end

    context 'invalid data' do
      let!(:duplicate_deal) { create :deal, name: FFaker::NatoAlphabet.callsign }
      let!(:duplicate_deal2) { create :deal, name: duplicate_deal.name }

      it 'requires deal ID to match' do
        data = build :deal_product_budget_csv_data, deal_id: 0
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal ID #{data[:deal_id]} could not be found"]])
      end

      it 'requires deal name to be present' do
        data = build :deal_product_budget_csv_data
        data[:deal_name] = nil
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name can't be blank"]])
      end

      it 'requires deal name to match only 1 record' do
        data = build :deal_product_budget_csv_data, deal_name: duplicate_deal.name
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name #{data[:deal_name]} matched more than one deal record"]])
      end

      it 'requires deal name to match at least one record' do
        data = build :deal_product_budget_csv_data, deal_name: 'N/A'
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Name #{data[:deal_name]} did not match any Deal record"]])
      end

      it 'requires deal product to be present' do
        data = build :deal_product_budget_csv_data
        data[:deal_product] = nil
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Product can't be blank"]])
      end

      it 'requires deal product to exist' do
        data = build :deal_product_budget_csv_data, deal_product: 'N/A'
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Product #{data[:deal_product]} could not be found"]])
      end

      it 'requires budget to be present' do
        data = build :deal_product_budget_csv_data
        data[:budget] = nil
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Budget can't be blank"]])
      end

      it 'validates numericality of budget' do
        data = build :deal_product_budget_csv_data, budget: 'test'
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Budget must be a numeric value"]])
      end

      it 'requires period to be present' do
        data = build :deal_product_budget_csv_data
        data[:period] = nil
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Period can't be blank"]])
      end

      it 'requires period to have Mon-YY format' do
        data = build :deal_product_budget_csv_data, period: 'N/A'
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Period must be in valid format: Mon-YY"]])
      end

      it 'requires period to be within Deal period' do
        data = build :deal_product_budget_csv_data, period: 'Jan-00'
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Period #{data[:period]} must be within Deal Period"]])
      end

      it 'rejects deal product budgets with same start date' do
        data = build :deal_product_budget_csv_data, deal_id: existing_deal.id
        DealProductBudget.import(generate_csv(data), user)
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Product Budget for #{data[:period]} month already exists"]])
      end

      it 'returns an error if deal product budgets already exist' do
        data = build :deal_product_budget_csv_data, deal_id: existing_deal.id
        product = company.products.where(name: data[:deal_product]).first
        existing_deal.deal_products.create(product: product, budget: 30_000)
        expect(
          DealProductBudget.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal Product #{data[:deal_product]} already exists"]])
      end
    end
  end
end
