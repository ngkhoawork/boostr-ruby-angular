require 'rails_helper'

describe Facts::AccountProductPipelineFactService do
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

    context 'when there are existing records in account pipeline table' do
      let!(:account_product_pipeline_fact) do
        create(:account_product_pipeline_fact,
               company: company,
               account_dimension: account_dimension,
               time_dimension: time_dimension,
               unweighted_amount: 30_000.00,
               weighted_amount: 0,
               process_ran_at: DateTime.now - 1.day)
      end

      subject(:perform_service) { described_class.perform(company_id: company.id, time_dimension: time_dimension) }

      it 'destroys records if nothing to recalculate' do
        expect{ perform_service }.to change{ AccountProductPipelineFact.count }.by(-1)
      end
    end

    context 'when there are no records in database' do
      let!(:time_dimension) do
        create(:time_dimension, start_date: deal_product_budget.start_date - 1, end_date: deal_product_budget.start_date + 1)
      end
      let(:account_dimension) { advertiser.account_dimensions[0] }

      subject(:perform_service) { described_class.perform(company_id: company.id, time_dimension: time_dimension) }

      it 'creates new account_pipeline fact' do
        expect{ perform_service }.to change{ AccountProductPipelineFact.count }.by(+1)
      end
    end

    context 'when there is a record in database' do
      let!(:deal_product_budget) { create(:deal_product_budget, deal_product: deal_product, budget: 2000.00) }
      let!(:account_product_pipeline_fact) do
        create(:account_product_pipeline_fact,
               company_id: company,
               account_dimension_id: account_dimension,
               time_dimension_id: time_dimension_in_bounds,
               unweighted_amount: 30_000.00,
               weighted_amount: 0)
      end

      subject(:perform_service) { described_class.perform(company_id: company.id, time_dimension: time_dimension_in_bounds) }

      it 'updates existing fact' do
        expect{ perform_service }.to change{ AccountProductPipelineFact.last.unweighted_amount }
      end
    end
  end

  private

  def time_dimension
    @time_dimension ||= create(:time_dimension, start_date: DateTime.now, end_date: DateTime.now + 31)
  end

  def company
    @company ||= create(:company)
  end

  def advertiser
    @advertiser ||= create(:client, company: company)
  end

  def account_dimension
    advertiser.account_dimensions[0]
  end

  def time_dimension_in_bounds
    @time_dimension_in_bounds ||= create(:time_dimension, start_date: deal_product_budget.start_date - 1, end_date: deal_product_budget.start_date + 1)
  end

  def deal_product_budget
    @deal_product_budget ||= create(:deal_product_budget, deal_product: deal_product, budget: 2000.00)
  end

  def deal_product
    @deal_product ||= create(:deal_product, deal: deal, open: true)
  end

  def deal
    @deal ||= create(:deal, advertiser: advertiser, agency: nil, company: company)
  end
end