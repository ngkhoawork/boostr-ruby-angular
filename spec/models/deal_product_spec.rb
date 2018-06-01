require 'rails_helper'

RSpec.describe DealProduct, type: :model do
  let!(:company) { create :company }
  let!(:product) { create :product }
  let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29) }
  let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 10_000 }

  describe '#update_budget' do
    it 'sets the budget to the sum of deal product budgets' do
      expect(deal_product.budget).to eq(10000)
      deal_product.deal_product_budgets.first.update(budget: 5000)
      deal_product.update_budget
      expect(deal_product.budget).to eq(deal_product.deal_product_budgets.sum(:budget))
    end
  end

  describe '#update_product_budgets' do
    it 'splits total budget over month and updates product budgets' do
      deal_product.update(budget: 90_000)
      deal_product.update_product_budgets
      deal_product_budgets = deal_product.deal_product_budgets
      expect(deal_product_budgets.count).to eq(2)
      expect(deal_product_budgets.map(&:budget)).to eq([8438, 81562])
    end
  end

  describe '#daily_budget' do
    it 'returns daily budget based on the deal start and end dates' do
      expect(deal_product.daily_budget).to eq(deal_product.budget / deal.days.to_f)
    end
  end

  context 'after_update' do
    it 'updates total deal budget' do
      deal = create :deal, start_date: Date.new(2015, 7, 1), end_date: Date.new(2015, 7, 29)
      deal_product = create :deal_product, deal: deal, product: product, budget: 1_000
      deal_product_budget = deal_product.deal_product_budgets.first

      deal_product.update(deal_product_budgets_attributes: { id: deal_product_budget.id, budget: 8888 })
      expect(deal.reload.budget.to_i).to eq(8888)
    end

    context 'when sum of deal product budgets is not equal to the total budget' do
      let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29) }
      let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 1_000 }

      it 'updates deal products if budget was updated' do
        deal_product.update(budget: 8888)
        expect(deal_product.deal_product_budgets.sum(:budget)).to eq(8888)
      end

      it 'updates total budget if budget was not updated' do
        deal_product_budget = deal_product.deal_product_budgets.first
        deal_product.update(deal_product_budgets_attributes: {id: deal_product_budget.id, budget: 90_000})
        expect(deal_product.budget).to eq(deal_product.deal_product_budgets.sum(:budget))
      end
    end

    context 'when sum of deal product budgets is equal to the total budget' do
      let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29) }
      let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 1_000 }

      it 'does not modify total budget or product budgets' do
        deal_product_budget = deal_product.deal_product_budgets.first
        deal_product.update(deal_product_budgets_attributes: {id: deal_product_budget.id, budget: 95_000})
        expect(deal_product.budget).to eq(95906)
        expect(deal_product.deal_product_budgets.sum(:budget)).to eq(95906)
      end
    end
  end

  describe '#import' do
    let!(:full_company) { create :company }
    let!(:user) { create :user, company: full_company }
    let!(:product) { create :product, company: full_company }
    let!(:existing_deal) { create :deal, company: full_company }
    let!(:three_month_deal) { create :deal, start_date: Date.new(2015, 7), end_date: Date.new(2015, 9).end_of_month, company: full_company }
    let!(:deal_with_product) { create :deal, company: full_company }
    let!(:existing_deal_product) { create :deal_product, deal: deal_with_product, product: product, budget: 1_000 }
    let(:import_log) { CsvImportLog.last }

    it 'creates new deal product' do
      data = build :deal_product_csv_data, company: full_company, deal_name: three_month_deal.name
      expect do
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')
      end.to change(DealProduct, :count).by(1)

      deal_product = DealProduct.last
      expect(deal_product.budget).to eq(data[:budget])
      expect(deal_product.product.name).to eq(data[:product])
      expect(deal_product.deal_product_budgets.count).to eq 3
      expect(deal_product.deal_product_budgets.sum(:budget)).to eq(data[:budget])
      expect(deal_product.deal.budget).to eq(data[:budget])
    end

    it 'updates existing deal product' do
      data = build :deal_product_csv_data, company: full_company, deal_id: deal_with_product.id, product: product.name, budget: 50_000
      expect do
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')
      end.not_to change(DealProduct, :count)

      deal_with_product.reload
      existing_deal_product.reload

      expect(deal_with_product.deal_products.count).to be 1
      expect(deal_with_product.budget.to_f).to eq (data[:budget])
      expect(existing_deal_product.budget.to_f).to eq (data[:budget])
      expect(existing_deal_product.deal_product_budgets.count).to be 2
    end

    context 'csv import log' do
      it 'creates csv import log' do
        data = build :deal_product_csv_data, company: full_company, deal_name: three_month_deal.name

        expect do
          DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')
        end.to change(CsvImportLog, :count).by(1)
      end

      it 'saves amount of processed rows for new objects' do
        data = build :deal_product_csv_data, company: full_company, deal_name: three_month_deal.name

        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
        expect(import_log.file_source).to eq 'deal_products.csv'
      end

      it 'saves amount of processed rows when updating existing objects' do
        data = build :deal_product_csv_data, company: full_company, deal_id: deal_with_product.id

        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
      end

      it 'counts failed rows' do
        data = build :deal_product_csv_data, company: full_company, deal_name: 'N/A'
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_failed).to be 1
      end
    end

    context 'invalid data' do
      let!(:duplicate_deal) { create :deal, company: full_company }
      let!(:duplicate_deal2) { create :deal, name: duplicate_deal.name, company: full_company }

      it 'requires deal ID to match' do
        data = build :deal_product_csv_data, company: full_company, deal_id: 0
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal ID #{data[:deal_id]} could not be found"] }]
        )
      end

      it 'requires deal name to be present' do
        data = build :deal_product_csv_data, company: full_company
        data[:deal_name] = nil
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Name can't be blank"] }]
        )
      end

      it 'requires deal name to match only 1 record' do
        data = build :deal_product_csv_data, company: full_company, deal_name: duplicate_deal.name
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Name #{data[:deal_name]} matched more than one deal record"] }]
        )
      end

      it 'requires deal name to match at least one record' do
        data = build :deal_product_csv_data, company: full_company, deal_name: 'N/A'
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Name #{data[:deal_name]} did not match any Deal record"] }]
        )
      end

      it 'requires product to be present' do
        data = build :deal_product_csv_data, company: full_company
        data[:product] = nil
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Product can't be blank"] }]
        )
      end

      it 'requires product to exist' do
        data = build :deal_product_csv_data, company: full_company, product: 'N/A'
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Product #{data[:product]} could not be found"] }]
        )
      end

      it 'requires budget to be present' do
        data = build :deal_product_csv_data, company: full_company
        data[:budget] = nil
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Budget can't be blank"] }]
        )
      end

      it 'validates numericality of budget' do
        data = build :deal_product_csv_data, company: full_company, budget: 'test'
        DealProduct.import(generate_csv(data), user.id, 'deal_products.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Budget must be a numeric value"] }]
        )
      end
    end

    context 'deal custom fields' do
      before do
        setup_custom_fields(full_company)
      end

      it 'imports deal product custom field' do
        data = build :deal_product_csv_data_custom_fields,
               company: full_company,
               deal_name: three_month_deal.name,
               custom_field_names: full_company.deal_product_cf_names

        expect do
          DealProduct.import(generate_csv(data), user.id, 'deals.csv')
        end.to change(DealProductCf, :count).by(1)

        custom_field = DealProductCf.last

        expect(custom_field.datetime1).to eq(data[:production_date])
        expect(custom_field.boolean1).to eq(data[:risky_click])
        expect(custom_field.number1.to_f).to eq(data[:target_views])
        expect(custom_field.text1).to eq(data[:deal_type])
      end
    end
  end

  describe '#to_csv' do
    before { create :deal_product_cf_name, company: company }

    let!(:product) { create :product, company: company }
    let!(:deal) { create :deal, start_date: Date.new(2015, 7, 29), end_date: Date.new(2015, 8, 29), company: company }
    let!(:deal_product) { create :deal_product, deal: deal, product: product, budget_loc: 100_000, budget: 100_000 }
    let!(:deal_product_cf) { create :deal_product_cf, company: company, deal_product: deal_product, text1: 'Joe Doe' }

    it 'returns correct headers' do
      deal_products = user.company.deal_products
      data = CSV.parse(Csv::DealProductService.new(company, deal_products).perform)

      expect(data[0]).to eq([
        'Deal_id',
        'Deal_name',
        'Advertiser',
        'Agency',
        'Deal_stage',
        'Deal_probability',
        'Deal_start_date',
        'Deal_end_date',
        'Deal_currency',
        'Product_name',
        'Product_budget',
        'Product_budget_USD',
        'Owner'
      ])
    end

    it 'returns correct data' do
      deal_products = user.company.deal_products
      data = CSV.parse(Csv::DealProductService.new(company, deal_products).perform)

      expect(data[1]).to eq([
        deal_product.deal.id,
        deal_product.deal.name,
        deal_product.deal.advertiser.name,
        deal_product.deal.agency.name,
        deal_product.deal.stage.name,
        deal_product.deal.stage.probability,
        deal_product.deal.start_date,
        deal_product.deal.end_date,
        deal_product.deal.curr_cd,
        deal_product.product.name,
        deal_product.budget_loc,
        deal_product.budget,
        deal_product_cf.text1
      ].map(&:to_s))
    end

    it 'does not fail when data is missing' do
      deal_product.deal.advertiser.destroy
      deal_product.deal.agency.destroy
      deal_product.deal.stage.destroy
      deal_product.product.destroy

      deal_products = user.company.deal_products
      deal_product_csv = CSV.parse(Csv::DealProductService.new(company, deal_products).perform)[1].to_csv

      expect(deal_product_csv).to eq([
        deal_product.deal.id,
        deal_product.deal.name,
        nil,
        nil,
        nil,
        nil,
        deal_product.deal.start_date,
        deal_product.deal.end_date,
        deal_product.deal.curr_cd,
        nil,
        deal_product.budget_loc,
        deal_product.budget,
        deal_product_cf.text1
      ].to_csv)
    end
  end

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def setup_custom_fields(company)
    create :deal_product_cf_name, field_type: 'datetime', field_label: 'Production Date', company: company
    create :deal_product_cf_name, field_type: 'boolean',  field_label: 'Risky Click?', company: company
    create :deal_product_cf_name, field_type: 'number',   field_label: 'Target Views', company: company
    create :deal_product_cf_name, field_type: 'text',     field_label: 'Deal Type', company: company
  end
end
