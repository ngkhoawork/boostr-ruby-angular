require 'rails_helper'

RSpec.describe ForecastTeam do
    let(:company) { create :company }
    let(:leader) { create :user, company: company }
    let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
    let(:client) { create :client, company: company }

  context 'with a leader' do
    let(:team) { create :parent_team, company: company, leader: leader }
    let(:member) { create :user, company: company, team: team }
    let(:forecast) { ForecastTeam.new(team, time_period) }
    let!(:leader_quota) { create :quota, user: leader, value: 5000, time_period: time_period }
    let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period }

    it 'returns the revenue for a member that has no revenue' do
      expect(forecast.revenue).to eq(0)
    end

    context 'with revenue' do
      it 'sums the split revenue' do
        another_user = create(:user, company: company, team: team)
        client.client_members.create(user: leader, share: 50, role: 'Member')
        client.client_members.create(user: another_user, share: 50, role: 'Member')
        today = Time.parse("2015-09-17")
        create_list :revenue, 10, company: company, client: client, user: leader, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end
    end

    context 'weighted_pipeline' do
      let(:stage) { create :stage, probability: 50 }
      let(:deal) { create :deal, company: company, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
      let!(:deal_product) { create_list :deal_product, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

      it 'sums the weighted_pipeline' do
        create :deal_member, deal: deal, user: leader, share: 50
        create :deal_member, deal: deal, user: member, share: 50

        expect(forecast.weighted_pipeline).to eq(50)
      end
    end

    context 'quota' do
      it 'returns the quota value of the team leader' do
        expect(forecast.quota).to eq(5000)
      end
    end
  end

  context 'without a leader' do
    let(:team) { create :parent_team, company: company }
    let(:member) { create :user, company: company, team: team }
    let(:forecast) { ForecastTeam.new(team, time_period) }
    let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period }

    context 'with revenue' do
      it 'sums the split revenue' do
        another_user = create(:user, company: company, team: team)
        client.client_members.create(user: member, share: 50, role: 'Member')
        client.client_members.create(user: another_user, share: 50, role: 'Member')
        today = Time.parse("2015-09-17")
        create_list :revenue, 10, company: company, client: client, user: member, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end
    end

    context 'weighted_pipeline' do
      let(:stage) { create :stage, probability: 50 }
      let(:deal) { create :deal, company: company, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
      let!(:deal_product) { create_list :deal_product, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

      it 'sums the weighted_pipeline' do
        create :deal_member, deal: deal, user: member, share: 50
        expect(forecast.weighted_pipeline).to eq(25)
      end
    end

    context 'quota' do
      it 'returns the quota value of the team leader' do
        expect(forecast.quota).to eq(0)
      end
    end
  end
end
