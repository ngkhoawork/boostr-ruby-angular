require 'rails_helper'

RSpec.describe Deal, type: :model do
  let(:company) { Company.first }
  let(:user) { create :user }

  context 'associations' do
    it { should have_many(:contacts).through(:deal_contacts) }
    it { should have_many(:deal_contacts) }
  end

  context 'scopes' do

    context 'for_client' do
      let!(:deal) { create :deal }
      let(:agency) { create :client }
      let!(:another_deal) { create :deal, agency: agency }

      it 'returns all when client_id is nil' do
        expect(Deal.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Deal.for_client(agency.id).count).to eq(1)
      end
    end

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31' }
      let!(:in_deal) { create :deal, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal) { create :deal, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'should return deals that are completely in the time period' do
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date)).to include(in_deal)
      end

      it 'returns deals that are partially in the time period' do
        create :deal, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end

    context 'open' do
      let(:closed_stage) { create :stage, open: false }
      let(:open_stage) { create :stage, open: true }
      let!(:open_deal) { create :deal, stage: open_stage }
      let!(:closed_deal) { create :deal, stage: closed_stage }

      it 'returns only deals that have an open stage' do
        expect(Deal.all.length).to eq(2)
        expect(Deal.open.length).to eq(1)
        expect(Deal.open).to include(open_deal)
      end
    end
  end

  describe '#in_period_amt' do
    let(:deal) { create :deal }
    let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-01-31' }

    it 'returns 0 when there are no deal products' do
      expect(deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(0)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      create :deal_product, deal: deal, start_date: '2015-01-01', end_date: '2015-01-31', budget: 100000

      expect(deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(1000)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      create :deal_product, deal: deal, start_date: '2015-01-27', end_date: '2015-02-05', budget: 100000

      expect(deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(500)
    end
  end

  describe '#days' do
    let(:deal) { create :deal, start_date: Date.new(2015, 1, 1), end_date: Date.new(2015, 1, 31) }

    it 'returns the number of days between the start and end dates.' do
      expect(deal.days).to eq(31)
    end
  end

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28) }

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#add_product' do
    let(:product) { create :product }

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expected_budgets = [600_000, 3_100_000, 3_000_000, 2_800_000]
      expect do
        deal.add_product(product.id, '95000')
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(9_500_000)
      end.to change(DealProduct, :count).by(4)
    end

    it 'creates the correct number of DealProduct objects based on the deal timeline' do
      deal = create :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)

      expected_budgets = [3_617_021, 6_382_979]
      expect do
        deal.add_product(product.id, '100000')
        expect(DealProduct.all.map(&:budget)).to eq(expected_budgets)
        expect(deal.budget).to eq(10_000_000)
      end.to change(DealProduct, :count).by(2)
    end
  end

  describe '#remove_product' do
    let(:deal) { create :deal }
    let(:product) { create :product }
    let!(:deal_product) { create :deal_product, deal: deal, product: product, start_date: deal.start_date, end_date: deal.start_date.end_of_month }

    it 'deletes a product from a deal' do
      expect do
        deal.remove_product(product.id)
      end.to change(DealProduct, :count).by(-1)
    end
  end

  describe '#days_per_month' do
    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expect(deal.days_per_month).to eq([6, 31, 30, 28])
    end

    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([17, 30])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([6])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 10, 15)
      expect(deal.days_per_month).to eq([6, 15])
    end
  end

  describe '#reset_products' do
    let(:deal) { create :deal }
    let(:product) { create :product }

    it 'deletes and recreates deal_products based on the start or end date changing' do
      deal.add_product(product.id, 10_000)
      expect do
        deal.update_attributes(end_date: Date.new(2015, 9, 29))
      end.to change(DealProduct, :count).by(1)
    end
  end

  describe '#generate_deal_members' do
    let(:client) { create :client }
    let!(:client_role_owner) { create :option, field: client_role_field(company), name: "Owner" }
    let(:role) { create :value, field: client_role_field(company), option: client_role_owner }
    let!(:client_member) { create :client_member, user: user, client: client, values: [role] }
    let(:deal) { build :deal, advertiser: client }

    it 'creates deal_members with defaults when creating a deal' do
      expect do
        deal.save
      end.to change(DealMember, :count).by(1)
      expect(DealMember.first.deal_id).to eq(deal.id)
      expect(DealMember.first.user_id).to eq(client_member.user_id)
      expect(DealMember.first.values.first.option_id).to eq(role.option_id)
      expect(DealMember.first.share).to eq(client_member.share)
    end

    context 'when there are no client members' do
      let!(:client_wo_members) { create :client }
      let!(:deal) { build :deal, advertiser: client_wo_members, creator: user }

      it 'assigns 100 percent share to the deal creator' do
        expect do
          deal.save
        end.to change(DealMember, :count).by(1)
        expect(deal.deal_members.count).to be(1)
        expect(deal.deal_members.first.user_id).to be(user.id)
        expect(deal.deal_members.first.share).to be(100)
      end
    end
  end

  context 'to_zip' do
    let(:deal) { create :deal, name: 'Bob' }
    let(:product) { create :product }
 
    it 'returns the contents of deal zip' do
      deal.add_product(product.id, 10_000)
      deal_zip = Deal.to_zip
      expect(deal_zip).not_to be_nil
    end
  end

  context 'after_update' do
    let(:user) { create :user }
    let(:stage) { create :stage }
    let(:stage1) { create :stage }
    let(:deal) { create :deal, stage: stage, creator: user, updator: user, stage_updator: user, stage_updated_at: Date.new }
    it 'create deal_steage_log' do
      deal.update_attributes(stage: stage1)
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'U')).not_to be_nil
    end
  end

  context 'after_destroy' do
    let(:user) { create :user }
    let(:stage) { create :stage }
    let(:deal) { create :deal, stage: stage, creator: user, updator: user, stage_updator: user, stage_updated_at: Date.new }
    it 'create deal_steage_log' do
      deal.destroy
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'D')).not_to be_nil
    end
  end
end
