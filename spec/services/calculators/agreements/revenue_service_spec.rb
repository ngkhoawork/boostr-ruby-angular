require 'rails_helper'

describe 'Calculators::Agreements::RevenueService' do
  describe '.perform' do
    context 'when within agreement period' do
      context 'when there are content fee products' do
        it 'calculates revenue' do
          deal = create_deals(1, agency: agency, advertiser: advertiser, start_date: '05-05-1989', end_date: '05-05-1989').first
          sa(client_ids: [advertiser.id, agency.id], start_date: deal.start_date, end_date: deal.start_date)
          io(deal: deal, company: company)
          content_fee(io: io)
          content_fee_product_budget(content_fee: content_fee, start_date: deal.start_date, end_date: deal.end_date)

          result = Calculators::Agreements::RevenueService.new(agreement_start_date: sa.start_date,
                                                               agreement_end_date: sa.end_date,
                                                               agreement_id: sa.id).perform
          expect(result[:revenue_amount]).to eq(content_fee_product_budget.budget)
        end
      end

      context 'when there are display line item products' do
        it 'calculates revenue' do
          deal = create_deals(1, agency: agency, advertiser: advertiser, start_date: '05-05-1989', end_date: '05-05-1989').first
          sa(client_ids: [advertiser.id, agency.id], start_date: deal.start_date, end_date: deal.start_date)
          io(deal: deal, company: company)
          display_line_item(io: io)
          display_line_item_budget(display_line_item: display_line_item,
                                   start_date: deal.start_date,
                                   end_date: deal.end_date)

          result = Calculators::Agreements::RevenueService.new(agreement_start_date: sa.start_date,
                                                               agreement_end_date: sa.end_date,
                                                               agreement_id: sa.id).perform
          expect(result[:revenue_amount]).to eq(display_line_item_budget.budget)
        end
      end
    end
  end

  private

  def display_line_item(opts={})
    @_display_line_item ||= create(:display_line_item, opts)
  end

  def content_fee(opts={})
    @_content_fee ||= create(:content_fee, opts)
  end

  def content_fee_product_budget(opts={})
    @_content_fee_product_budget ||= create(:content_fee_product_budget, opts)
  end

  def display_line_item_budget(opts = {})
    @_display_line_item_budget ||= create(:display_line_item_budget, opts)
  end

  def io(opts={})
    @_io ||= create(:io, opts)
  end

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
end