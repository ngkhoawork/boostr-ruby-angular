require 'rails_helper'

describe 'Calculators::Agreements::PipelineService' do
  describe '.perform' do
    context 'when product is open' do
      context 'STAGE does not = Closed Won / Closed Lost' do
        context 'deal is included in agreement' do
          context 'when campaign period has dates are included in the spend agreement period' do
            it 'calculates weighted pipeline for given spend agreement' do
              deal = create_deals(1,
                                  agency: agency,
                                  advertiser: advertiser,
                                  start_date: '11-03-2017',
                                  end_date: '11-03-2017').first

              deal_product(deal_id: deal.id)
              deal_product_budget(start_date: deal.start_date,
                                  end_date: deal.start_date,
                                  deal_product: deal_product,
                                  budget: 1501)

              sa(client_ids: [advertiser.id, agency.id],
                 start_date: deal.start_date,
                 end_date: deal.start_date)

              result = Calculators::Agreements::PipelineService.new(agreement_start_date: sa.start_date,
                                                                    agreement_end_date: sa.end_date,
                                                                    agreement_id: sa.id).perform

              expected_amount = deal.deal_product_budgets.sum(:budget).round * deal.stage.probability / 100

              expect(result[:weighted_pipeline]).to eq(expected_amount)
            end

            it 'calculates unweighted pipeline for given spend agreement' do
              deal = create_deals(1,
                                  agency: agency,
                                  advertiser: advertiser,
                                  start_date: '11-03-2017',
                                  end_date: '11-03-2017').first

              deal_product(deal_id: deal.id)
              deal_product_budget(start_date: deal.start_date,
                                  end_date: deal.start_date,
                                  deal_product: deal_product,
                                  budget: 1000)
              sa(client_ids: [advertiser.id, agency.id],
                 start_date: deal.start_date,
                 end_date: deal.start_date)

              result = Calculators::Agreements::PipelineService.new(agreement_start_date: sa.start_date,
                                                                    agreement_end_date: sa.end_date,
                                                                    agreement_id: sa.id).perform
              expected_amount = deal.deal_product_budgets.sum(:budget).round

              expect(result[:unweighted_pipeline]).to eq(expected_amount)
            end
          end

          context 'when campaign period has dates are not included in the spend agreement period' do

            it 'calculates weighted pipeline for given spend agreement' do
              deal = create_deals(1,
                                  agency: agency,
                                  advertiser: advertiser,
                                  start_date: '11-03-2017',
                                  end_date: '11-03-2017').first

              deal_product(deal_id: deal.id)
              deal_product_budget(start_date: deal.start_date,
                                  end_date: deal.start_date,
                                  deal_product: deal_product,
                                  budget: 1000)
              sa(client_ids: [advertiser.id, agency.id],
                 start_date: deal.start_date,
                 end_date: deal.start_date)

              deal.deal_product_budgets.update_all(start_date: '11-04-2017')

              result = Calculators::Agreements::PipelineService.new(agreement_start_date: sa.start_date,
                                                                    agreement_end_date: sa.end_date,
                                                                    agreement_id: sa.id).perform
              expect(result[:weighted_pipeline]).to eq(0)
            end

            it 'calculates unweighted pipeline for given spend agreement' do
              deal = create_deals(1,
                                  agency: agency,
                                  advertiser: advertiser,
                                  start_date: '11-03-2017',
                                  end_date: '11-03-2017').first

              deal_product(deal_id: deal.id)
              deal_product_budget(start_date: deal.start_date,
                                  end_date: deal.start_date,
                                  deal_product: deal_product,
                                  budget: 1000)
              sa(client_ids: [advertiser.id, agency.id],
                 start_date: deal.start_date,
                 end_date: deal.start_date)

              deal.deal_product_budgets.update_all(start_date: '11-04-2017')

              result = Calculators::Agreements::PipelineService.new(agreement_start_date: sa.start_date,
                                                                    agreement_end_date: sa.end_date,
                                                                    agreement_id: sa.id).perform
              expect(result[:unweighted_pipeline]).to eq(0)
            end
          end
        end
      end
    end
  end

  private

  def sa(opts={})
    defaults = {
        client_ids: [advertiser.id, agency.id],
        manually_tracked: false,
        start_date: Date.new(2017, 1, 1),
        end_date: Date.new(2017, 12, 31),
        holding_company: nil
    }

    @sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def company
    @_company ||= create(:company)
  end

  def create_deals(count=1, opts={})
    defaults = {
        agency: agency,
        advertiser: advertiser,
        start_date: Date.new(2017, 1, 1),
        end_date: Date.new(2017, 12, 31),
        manual_update: true,
        company: company
    }

    create_list :deal, count, defaults.merge(opts)
  end

  def advertiser(opts={})
    defaults = { company: company }
    @advertiser ||= create(:client, :advertiser, defaults.merge(opts))
  end

  def agency(opts={})
    defaults = { company: company }
    @agency ||= create(:client, :agency, defaults.merge(opts))
  end

  def deal_product_budget(opts={})
    @_dpb ||= create(:deal_product_budget, opts)
  end

  def stage(opts={})
    @_stage ||= create(:stage, probability: 75, open: true, active: true)
  end

  def deal_product(opts={})
    @_deal_product ||= create(:deal_product, opts)
  end
end