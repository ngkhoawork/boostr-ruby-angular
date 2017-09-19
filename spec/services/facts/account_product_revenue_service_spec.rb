require 'rails_helper'

describe Facts::AccountProductRevenueFactService do

  describe '#perform' do
    let!(:time_dimension) { create(:time_dimension, start_date: Date.today, end_date: Date.today + 2.days) }
    let(:company) { create(:company) }
    let(:client) { create(:client, company: company) }
    let(:deal) { create(:deal, advertiser: client, agency: nil)}
    let(:io) {create(:io, advertiser: client, agency: nil, deal: deal)}
    let(:display_product) { create(:product, revenue_type: 'Display', company: company) }
    let(:content_fee_product) { create(:product, revenue_type: 'Content-Fee', company: company) }

    subject { -> { described_class.new.perform } }

    context 'calculation for content fee products' do

      let!(:account_dimension) { create(:account_dimension, id: client.id, name: client.name, account_type: 10) }
      # let!(:product_dimension) { create(:product_dimension, id: content_fee_product.id, name: content_fee_product.name, revenue_type: content_fee_product.revenue_type, company_id: content_fee_product.company_id) }
      let(:content_fee) { create(:content_fee, product: content_fee_product, io: io) }
      let!(:content_fee_product_budget) { create(:content_fee_product_budget, content_fee: content_fee, budget: 1000, start_date: Date.today, end_date: Date.today + 2.day) }
      let!(:content_fee_product_budget_1) { create(:content_fee_product_budget, content_fee: content_fee, budget: 2000, start_date: Date.today, end_date: Date.today + 2.day) }
      #TODO fix according to Nik changes

      xit 'adds new entry in account product revenue facts for matching month' do
        expect{ subject.call }.to change{ AccountProductRevenueFact.count }.by(+1)
      end
      #TODO fix according to Nik changes

      xit 'summing the product amount for the matching month for each entry in time_dim' do
        subject.call
        expect(AccountProductRevenueFact.last.revenue_amount).to eq(content_fee_product_budget.budget + content_fee_product_budget_1.budget)
      end

      context 'updating existing revenue amount if recalculated' do
        let(:account_product_revenue_fact_params){ { account_dimension_id: client.id,
                                                     time_dimension_id: time_dimension.id,
                                                     company_id: company.id,
                                                     product_dimension_id: product_dimension.id,
                                                     revenue_amount: 1000 } }
        let!(:account_product_revenue_facts) { create(:account_product_revenue_facts, account_product_revenue_fact_params)}
        xit 'updates existing value if revenue amount recalculated' do
          expect{ subject.call }.to change{ AccountProductRevenueFact.last.revenue_amount }.from(account_product_revenue_fact.revenue_amount).to(content_fee_product_budget.budget.to_i + content_fee_product_budget_1.budget.to_i)
        end
      end
    end

    context 'calculation for display type products' do
      let!(:account_dimension) { create(:account_dimension, id: client.id, name: client.name, account_type: 10) }
      # let!(:product_dimension) { create(:product_dimension, id: display_product.id, name: display_product.name, revenue_type: display_product.revenue_type, company_id: display_product.company_id)}
      let(:display_line_item) { create(:display_line_item, product: display_product, io: io) }
      let!(:display_line_item_budget) { create(:display_line_item_budget, display_line_item: display_line_item, budget: 1000, start_date: Date.today, end_date: Date.today + 2.day)}
      let!(:display_line_item_budget_1) { create(:display_line_item_budget, display_line_item: display_line_item, budget: 2000, start_date: Date.today, end_date: Date.today + 2.day)}
      #TODO fix according to Nik changes

      xit 'calculates revenues as sum of display line item budget budgets' do
        subject.call
        expect(AccountProductRevenueFact.last.revenue_amount).to eq(display_line_item_budget.budget + display_line_item_budget_1.budget)
      end

      context 'display line items without display line item budgets' do
        # let(:product) { create(:product, revenue_type: 'Display', company: company) }
        let!(:account_dimension) { create(:account_dimension, id: client.id, name: client.name, account_type: 10) }
        let!(:product_dimension) { create(:product_dimension, id: display_product.id, name: display_product.name, revenue_type: display_product.revenue_type, company_id: display_product.company_id)}
        let!(:display_line_item) { create(:display_line_item, product: display_product, io: io) }
        #TODO fix according to Nik changes
        xit 'calculates revenues summing display line item budgets ' do
          subject.call
          expect(AccountProductRevenueFact.last.revenue_amount).to eq(display_line_item.budget)
        end
      end
    end
  end

end