require 'rails_helper'

RSpec.describe ForecastTeam, skip: true do
    let(:company) { Company.first }
    let(:leader) { create :user, win_rate: 0.5, average_deal_size: 100 }
    let(:time_period) { create :time_period, start_date: "2015-01-01", end_date: "2015-12-31" }
    let(:client) { create :client }

  context 'with a leader' do
    let(:team) { create :parent_team, leader: leader }
    let(:member) { create :user, team: team, win_rate: 0.5, average_deal_size: 100 }
    let!(:leader_quota) { create :quota, user: leader, value: 5000, time_period: time_period }
    let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period }
    let(:stage) { create :stage, probability: 50 }
    let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
    let(:deal_product) { create :deal_product, deal: deal, budget: 10000 }
    let!(:deal_product_budget) { create_list :deal_product_budget, 4, deal_product: deal_product, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }
    let!(:deal_member1) { create :deal_member, deal: deal, user: leader, share: 50 }
    let!(:deal_member2) { create :deal_member, deal: deal, user: member, share: 50 }
    let(:forecast) { ForecastTeam.new(team, time_period.start_date, time_period.end_date) }

    it 'returns the revenue for a member that has no revenue' do
      expect(forecast.revenue).to eq(0)
    end

    context 'with revenue' do
      it 'sums the split revenue' do
        another_user = create(:user, team: team)
        client.client_members.create(user: leader, share: 50, values: [create_member_role(company)])
        client.client_members.create(user: another_user, share: 50, values: [create_member_role(company, "Member")])
        today = Time.parse("2015-09-17")
        create_list :revenue, 10, client: client, user: leader, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end
    end

    context 'weighted_pipeline' do
      it 'sums the weighted_pipeline' do
        expect(forecast.weighted_pipeline).to eq(50)
      end
    end

    context 'quota' do
      it 'returns the quota value of the team leader' do
        expect(forecast.quota).to eq(5000)
      end
    end

    context 'gap_to_quota' do
      it 'returns the gap to quota value' do
        expect(forecast.revenue).to eq(0)
        expect(forecast.weighted_pipeline).to eq(50)
        expect(forecast.gap_to_quota).to eq(4950)
      end
    end

    context 'new_deals_needed' do
      it 'returns the number of new deals needed to meet the quota' do
        expect(forecast.gap_to_quota).to eq(4950)
        expect(forecast.new_deals_needed).to eq(100)
      end
    end
  end

  context 'parents' do
    let(:parent_parent_team) { create :parent_team }
    let(:parent_team) { create :parent_team, parent: parent_parent_team }
    let(:team) { create :parent_team, parent: parent_team }
    let(:forecast) { ForecastTeam.new(team, time_period.start_date, time_period.end_date) }

    it "has parent teams" do
      expect(forecast.parents).to eq([
        { id: parent_parent_team.id, name: parent_parent_team.name },
        { id: parent_team.id, name: parent_team.name }
      ])
    end
  end

  context 'without a leader' do
    let(:team) { create :parent_team }
    let(:member) { create :user, team: team }
    let(:forecast) { ForecastTeam.new(team, time_period.start_date, time_period.end_date) }
    let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period }

    context 'with revenue' do
      it 'sums the split revenue' do
        another_user = create(:user, team: team)
        client.client_members.create(user: member, share: 50, values: [create_member_role(company)])
        client.client_members.create(user: another_user, share: 50, values: [create_member_role(company, "Member")])
        today = Time.parse("2015-09-17")
        create_list :revenue, 10, client: client, user: member, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end
    end

    context 'weighted_pipeline' do
      let(:stage) { create :stage, probability: 50 }
      let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
      let(:deal_product) { create :deal_product, deal: deal, budget: 10000 }
      let!(:deal_product_budget) { create_list :deal_product_budget, 4, deal_product: deal_product, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

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
