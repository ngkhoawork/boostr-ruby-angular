require 'rails_helper'

RSpec.describe Forecast do
  context 'as_json' do
    let!(:company) { create :company, :fast_create_company }
    let(:leader) { create :user }
    let(:parent) { create :parent_team }
    let(:child) { create :child_team, parent: parent, leader: leader }
    let!(:user) { create :user, team: child }
    let(:time_period) { create :time_period }
    let(:forecast) { Forecast.new(company, company.teams.roots(true), time_period.start_date, time_period.end_date) }

    it 'returns all root teams and nested teams and members' do
      expect(forecast.teams.length).to eq(1)
      expect(forecast.teams[0].teams.length).to eq(1)
      expect(forecast.teams[0].teams[0].members.length).to eq(1)
      expect(forecast.weighted_pipeline).to eq(0)
    end
  end
end
