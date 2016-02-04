require 'rails_helper'

RSpec.describe ForecastMember do
  context 'as_json' do
    let(:company) { create :company }
    let(:parent) { create :parent_team, company: company }
    let(:child) { create :child_team, company: company, parent: parent }
    let(:user) { create :user, company: company, team: child }
    let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
    let(:forecast) { ForecastMember.new(user, time_period.start_date, time_period.end_date) }
    let(:client) { create :client, company: company }

    it 'returns the revenue for a member that has no revenue' do
      expect(forecast.revenue).to eq(0)
    end

    context 'with revenue' do
      it 'sums the revenue' do
        client.client_members.create(user: user, share: 100, values: [create_member_role(company)])
        today = Time.parse("2015-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end

      it 'sums the split revenue' do
        another_user = create(:user, company: company, team: child)
        client.client_members.create(user: user, share: 50, values: [create_member_role(company)])
        client.client_members.create(user: another_user, share: 50, values: [create_member_role(company, "Member")])
        today = Time.parse("2015-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(5000)
      end

      it 'does not sum revenue outside of the time period' do
        client.client_members.create(user: user, share: 100, values: [create_member_role(company)])
        today = Time.parse("2013-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(0)
      end

      it 'returns week over week revenue' do
        client.client_members.create(user: user, share: 100, values: [create_member_role(company)])
        create :revenue, company: company, client: client, user: user, budget: 500, start_date: '2015-01-01', end_date: '2015-01-10'
        create :snapshot, company: company, user: user, time_period: time_period
        create :revenue, company: company, client: client, user: user, budget: 1000, start_date: '2015-01-11', end_date: '2015-01-20'
        create :snapshot, company: company, user: user, time_period: time_period

        expect(forecast.wow_revenue).to eq(1000)
      end
    end

    context 'weighted_pipeline' do
      let(:stage) { create :stage, probability: 100 }
      let(:deal) { create :deal, company: company, stage: stage, start_date: "2015-01-01", end_date: "2015-1-31"  }
      let!(:deal_member) { create :deal_member, deal: deal, user: user, share: 100 }
      let!(:deal_product) { create_list :deal_product, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

      it 'sums the weighted_pipeline' do
        expect(forecast.weighted_pipeline).to eq(100)
      end

      it 'sums the split weighted_pipeline' do
        deal_member.update_attributes(share: 50)
        expect(forecast.weighted_pipeline).to eq(50)
      end

      it 'does not include closed deals' do
        stage.update_attributes(open: false)
        expect(forecast.weighted_pipeline).to eq(0)
      end

      it 'does not sum revenue outside of the time period' do
        time_period.update_attributes(start_date: "2015-01-15")
        expect(forecast.weighted_pipeline).to eq(54.83870967741935)
      end

      it 'applies the probability to the total' do
        stage.update_attributes(probability: 50)
        expect(forecast.weighted_pipeline).to eq(50)
      end

      it 'returns week over week weighted_pipeline' do
        create :snapshot, company: company, user: user, time_period: time_period
        stage.update_attributes(probability: 50)
        create :snapshot, company: company, user: user, time_period: time_period

        expect(forecast.wow_weighted_pipeline).to eq(-50)
      end
    end

    context 'weighted_pipeline_by_stage' do
      let(:stage) { create :stage, company: company, probability: 50 }
      let(:deal) { create :deal, company: company, stage: stage, start_date: "2015-01-01", end_date: "2015-1-31"  }
      let!(:deal_member) { create :deal_member, deal: deal, user: user, share: 100 }
      let!(:deal_product) { create_list :deal_product, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }
      let(:another_stage) { create :stage, company: company, probability: 90 }
      let(:another_deal) { create :deal, company: company, stage: another_stage, start_date: "2015-01-01", end_date: "2015-1-31"  }
      let!(:another_deal_member) { create :deal_member, deal: another_deal, user: user, share: 100 }
      let!(:another_deal_product) { create_list :deal_product, 4, deal: another_deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

      it 'lists the weighted pipeline by stage' do
        stages = {}
        stages[stage.id] = 50
        stages[another_stage.id] = 90

        expect(forecast.weighted_pipeline_by_stage).to eq(stages)
      end

      it 'lists the stages in the weighted pipeline by stage data' do
        expect(forecast.stages).to eq([stage, another_stage])
      end
    end

    context 'quota' do
      let!(:quotas) { create_list :quota, 4, user: user, value: 2500, time_period: time_period, company: company }

      it 'returns the quota value' do
        expect(forecast.quota).to eq(10000)
      end
    end
  end
end