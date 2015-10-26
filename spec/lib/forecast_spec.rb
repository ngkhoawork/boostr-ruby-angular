require 'rails_helper'

RSpec.describe Forecast do
  context 'as_json' do
    let(:company) { create :company }
    let(:leader) { create :user, company: company }
    let(:parent) { create :parent_team, company: company }
    let(:child) { create :child_team, company: company, parent: parent, leader: leader }
    let!(:user) { create :user, company: company, team: child }
    let(:time_period) { create :time_period, company: company }
    let(:forecast) { Forecast.new(company, company.teams.roots(true), time_period) }

    it 'returns all root teams and nested teams and members' do
      expect(forecast.teams.length).to eq(1)
      expect(forecast.teams[0].teams.length).to eq(1)
      expect(forecast.teams[0].teams[0].members.length).to eq(1)
      expect(forecast.weighted_pipeline).to eq(0)
    end
  end
end
