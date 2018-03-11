require 'rails_helper'

describe Facts::AccountProductRevenueFactService do

  describe '.perform' do

    before do
      Io.skip_callback(:save, :after, :update_revenue_fact_callback)
      ContentFee.skip_callback(:save, :after, :update_revenue_fact_callback)
      DisplayLineItem.skip_callback(:save, :after, :update_revenue_fact_callback)
    end

    after do
      Io.set_callback(:save, :after, :update_revenue_fact_callback)
      ContentFee.set_callback(:save, :after, :update_revenue_fact_callback)
      DisplayLineItem.set_callback(:save, :after, :update_revenue_fact_callback)
    end

    subject(:service_perform) { described_class.perform(time_dimension: time_dimension, company_id: company.id) }

    context 'calculation for content fee products' do

      let(:content_fee) { create(:content_fee, product: content_fee_product, io: io) }
      let!(:content_fee_product_budget) do
        create(:content_fee_product_budget,
               content_fee: content_fee,
               budget: 1000,
               start_date: time_dimension.start_date,
               end_date: time_dimension.end_date)
      end
      let!(:content_fee_product_budget_1) do
        create(:content_fee_product_budget,
               content_fee: content_fee,
               budget: 2000,
               start_date: time_dimension.start_date,
               end_date: time_dimension.end_date)
      end

      it 'adds new entry in account product revenue facts for matching month' do
        expect{ service_perform }.to change{ AccountProductRevenueFact.count }.by(+1)
      end

      it 'summing the product amount for the matching month for each entry in time_dim' do
        service_perform

        expect(AccountProductRevenueFact.last.revenue_amount).to eq(content_fee_product_budget.budget + content_fee_product_budget_1.budget)
      end

      context 'updating existing revenue amount if recalculated' do
        let!(:account_product_revenue_fact) do
          create(:account_product_revenue_fact,
                 account_dimension_id: account_dimension.id,
                 time_dimension_id: time_dimension.id,
                 company_id: company.id,
                 product_dimension_id: content_fee_product.id,
                 revenue_amount: 1000)
        end

        it 'updates existing value if revenue amount recalculated' do
          expect{ service_perform }.to change{ AccountProductRevenueFact.last.revenue_amount }.from(account_product_revenue_fact.revenue_amount).to(content_fee_product_budget.budget.to_i + content_fee_product_budget_1.budget.to_i)
        end
      end
    end

    context 'calculation for display type products' do
      let(:display_line_item) do
        create(:display_line_item,
               product: display_product,
               io: io)
      end
      let!(:display_line_item_budget) do
        create(:display_line_item_budget,
               display_line_item: display_line_item,
               budget: 1000,
               start_date: time_dimension.start_date,
               end_date: time_dimension.end_date)
      end
      let!(:display_line_item_budget_1) do
        create(:display_line_item_budget,
               display_line_item: display_line_item,
               budget: 2000,
               start_date: time_dimension.start_date,
               end_date: time_dimension.end_date)
      end

      it 'calculates revenues as sum of display line item budget budgets' do
        service_perform

        expect(AccountProductRevenueFact.last.revenue_amount).to eq(display_line_item_budget.budget + display_line_item_budget_1.budget)
      end
    end

    context 'display line items without display line item budgets' do
      let(:io) do
        create(:io,
               advertiser_id: account_dimension.id,
               agency: nil,
               deal: deal,
               company: company)
      end
      let!(:display_line_item) do
        create(:display_line_item,
               product: display_product,
               io: io,
               start_date: time_dimension.start_date,
               end_date: time_dimension.end_date,
               daily_run_rate: 1000)
      end

      it 'calculates revenues summing display line item budgets ' do
        service_perform

        expect(AccountProductRevenueFact.last.revenue_amount).to eq(display_line_item.daily_run_rate)
      end
    end
  end

  private

  def company
    @company ||= create(:company, :fast_create_company)
  end

  def client
    @client ||= create(:client, company: company)
  end

  def deal
    @deal ||= create(:deal, advertiser_id: account_dimension.id, agency: nil)
  end

  def io
    @io ||= create(:io, advertiser_id: account_dimension.id, agency: nil, deal: deal, company: company)
  end

  def display_product
    @display_product ||= create(:product, revenue_type: 'Display', company: company)
  end

  def content_fee_product
    @content_fee_product ||= create(:product, revenue_type: 'Content-Fee', company: company)
  end

  def account_dimension
    @account_dimension ||= client.account_dimensions[0]
  end

  def time_dimension
    @time_dimension ||= create(:time_dimension,
                               start_date: Date.today,
                               end_date: Date.today + 2.days)
  end
end