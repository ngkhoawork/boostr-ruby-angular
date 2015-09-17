require 'rails_helper'

RSpec.describe Forecast do
  context 'as_json' do
    let(:company) { create :company }
    let(:parent) { create :parent_team, company: company }
    let(:child) { create :child_team, company: company, parent: parent }
    let!(:user) { create :user, company: company, team: child }
    let(:time_period) { create :time_period, company: company }

    it 'returns all root teams and nested teams and members' do
      json = JSON.parse(Forecast.new(company.teams.roots(true), time_period).to_json)

      expect(json['teams'].length).to eq(1)
      expect(json['teams'][0]['teams'].length).to eq(1)
      expect(json['teams'][0]['teams'][0]['members'].length).to eq(1)
      expect(json['weighted_pipeline']).to eq(0)
    end
  end
end
