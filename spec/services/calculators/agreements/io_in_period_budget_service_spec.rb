require 'rails_helper'

describe 'Calculators::Agreements::IoInPeriodBudgetService' do
  describe '.perform' do
    let(:deal) do
      create(:deal,
             company: company,
             start_date: deal_start_date,
             end_date: deal_end_date)
    end
    let(:spend_agreement) do
      create(:spend_agreement,
             deals: [deal],
             clients: [deal.advertiser],
             company: company,
             start_date: spend_agreement_start_date,
             end_date: spend_agreement_end_date)
    end
    let(:company) { create(:company) }
    let(:io) { create(:io, deal: deal, company: company) }

    context 'when within agreement period' do
      let(:io_start_date) { '05-05-1989' }
      let(:io_end_date) { '05-05-1989' }
      let(:spend_agreement_start_date) { '05-05-1989' }
      let(:spend_agreement_end_date) { '05-05-1989' }
      let(:deal_start_date) { '05-05-1989' }
      let(:deal_end_date) { '05-05-1989' }

      context 'when there are content fee products' do
        let(:content_fee) { create(:content_fee, io: io) }
        let!(:content_fee_product_budget) do
          create(:content_fee_product_budget,
                 content_fee: content_fee,
                 start_date: io_start_date,
                 end_date: io_end_date)
        end
        let(:content_fee_budget) { content_fee_product_budget.budget }

        it 'calculates revenue' do
          result = Calculators::Agreements::IoInPeriodBudgetService.new(agreement_start_date: spend_agreement.start_date,
                                                               agreement_end_date: spend_agreement.end_date,
                                                               io_id: io.id).perform
          expect(result).to eq(content_fee_budget)
        end
      end

      context 'when there are display line item products' do
        let(:display_line_item) do
          create(:display_line_item, io: io)
        end
        let!(:display_line_item_budget) do
          create(:display_line_item_budget,
                 display_line_item: display_line_item,
                 start_date: io_start_date,
                 end_date: io_end_date)
        end
        let(:dli_budget) { display_line_item_budget.budget }

        it 'calculates revenue' do
          result = Calculators::Agreements::IoInPeriodBudgetService.new(agreement_start_date: spend_agreement.start_date,
                                                               agreement_end_date: spend_agreement.end_date,
                                                               io_id: io.id).perform
          expect(result).to eq(dli_budget)
        end
      end
    end
  end
end