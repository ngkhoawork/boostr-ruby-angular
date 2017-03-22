require 'rails_helper'

describe AccountPipelineCalculatorService do
  describe '#perform' do
    context 'when there are existing records in account pipeline table' do
      let(:company) { create(:company) }
      let(:advertiser) { create(:client, company: company) }
      let(:time_dimension) { create(:time_dimension) }
      let(:account_dimension) { create(:account_dimension, id: advertiser.id) }
      let!(:account_pipeline_fact) do
        create(:account_pipeline_fact,
               company_id: company.id,
               account_dimension_id: account_dimension.id, time_dimension_id: time_dimension.id )
      end

      it 'destroys records if nothing to recalculate' do
        expect{ AccountPipelineCalculatorService.new.perform }.to change{ AccountPipelineFact.count }.by(-1)
      end
    end
    context 'when there are no records in database' do
      let!(:company) { create(:company) }
      let!(:advertiser) { create(:client, company: company) }
      let!(:deal) { create(:deal, advertiser: advertiser, company: company) }
      let!(:deal_product) { create(:deal_product, deal: deal, open: false) }
      let!(:deal_product_budget) { create(:deal_product_budget, deal_product: deal_product, budget: 2000.00) }
      let!(:time_dimension) do
        create(:time_dimension, start_date: deal_product_budget.start_date - 1, end_date: deal_product_budget.start_date + 1)
      end
      let!(:account_dimension) { create(:account_dimension, id: advertiser.id) }

      it 'creates new account_pipeline fact' do
        expect{ AccountPipelineCalculatorService.new.perform }.to change{ AccountPipelineFact.count }.by(+1)
      end
    end

    context 'when there is a record in database' do
      let!(:company) { create(:company) }
      let!(:advertiser) { create(:client, company: company) }
      let!(:deal) { create(:deal, advertiser: advertiser, company: company) }
      let!(:deal_product) { create(:deal_product, deal: deal, open: false) }
      let!(:deal_product_budget) { create(:deal_product_budget, deal_product: deal_product, budget: 2000.00) }
      let!(:time_dimension) do
        create(:time_dimension, start_date: deal_product_budget.start_date - 1, end_date: deal_product_budget.start_date + 1)
      end
      let!(:account_dimension) { create(:account_dimension, id: advertiser.id) }
      let!(:account_pipeline_fact) do
        create(:account_pipeline_fact,
               company_id: company.id,
               account_dimension_id: account_dimension.id,
               time_dimension_id: time_dimension.id,
               pipeline_amount: 30_000.00
        )
      end

      it 'updates existing fact' do
        expect{ AccountPipelineCalculatorService.new.perform }.to change{ AccountPipelineFact.last.pipeline_amount }
      end
    end
  end
end