require 'rails_helper'

RSpec.describe ForecastMember do
  context 'as_json' do
    let(:company) { create :company }
    let(:leader) { create :user, company: company }
    let(:team) { create :parent_team, company: company, leader: leader }
    let(:member) { create :user, company: company, team: team }
    let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
    let(:forecast) { ForecastTeam.new(team, time_period) }
    let!(:leader_quota) { create :quota, user: leader, value: 5000, time_period: time_period }
    let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period }

    context 'quota' do
      it 'returns the quota value of the team leader' do
        expect(forecast.quota).to eq(5000)
      end
    end
  end
end
