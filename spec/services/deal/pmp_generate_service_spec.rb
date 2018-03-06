require 'rails_helper'

describe Deal::PmpGenerateService do
  describe '#perform' do
    context 'with closed stage' do
      it 'creates a pmp' do
        expect {
          described_class.new(deal).perform
        }.to change(Pmp, :count).by(1)

        pmp = Pmp.last
        expect(pmp.advertiser_id).to eq(deal.advertiser_id)
        expect(pmp.agency_id).to eq(deal.agency_id)
        expect(pmp.name).to eq(deal.name)
        expect(pmp.budget).to eq(deal.budget || 0)	 
        expect(pmp.budget_loc).to eq(deal.budget_loc || 0)
        expect(pmp.curr_cd).to eq(deal.curr_cd)
        expect(pmp.start_date).to eq(deal.start_date)
        expect(pmp.end_date).to eq(deal.end_date)
        expect(pmp.deal_id).to eq(deal.id)
      end

      it 'creates pmp members' do
        deal_member
        expect {
          described_class.new(deal).perform
        }.to change(PmpMember, :count).by(1)

        pmp_member = PmpMember.last
        pmp = Pmp.last
        expect(pmp_member.share).to eq(100)
        expect(pmp_member.from_date).to eq(deal.start_date)
        expect(pmp_member.to_date).to eq(deal.end_date)
        expect(pmp_member.pmp_id).to eq(pmp.id)
      end

      it 'creates pmp items' do
        deal_product
        expect {
          described_class.new(deal).perform
        }.to change(PmpItem, :count).by(1)

        pmp_item = PmpItem.last
        pmp = Pmp.last
        expect(pmp_item.ssp_id).to eq(ssp.id)
        expect(pmp_item.ssp_deal_id).to eq('ssp001')
        expect(pmp_item.budget).to eq(deal_product.budget)
        expect(pmp_item.budget_loc).to eq(deal_product.budget_loc)
      end
    end

    context 'with open stage' do
      let!(:stage) { create :stage, company: company, probability: 100, open: true }
      let!(:deal) { create :deal, company: company, stage: stage }
      let!(:pmp) { create :pmp, deal: deal }

      it 'deletes pmp' do
        expect {
          described_class.new(deal).perform
        }.to change(Pmp, :count).by(-1)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def stage
    @_stage ||= create :stage, company: company, probability: 100, open: false
  end

  def deal
    @_deal ||= create :deal, company: company, stage: stage
  end

  def deal_member
    @_deal_member ||= create :deal_member, deal: deal, share: 100
  end

  def product
    @_product ||= create :product, company: company
  end

  def ssp
    @_ssp ||= create :ssp
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product, ssp: ssp, ssp_deal_id: 'ssp001'
  end
end