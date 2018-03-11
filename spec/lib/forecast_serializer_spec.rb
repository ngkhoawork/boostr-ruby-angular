require 'rails_helper'

RSpec.describe ForecastSerializer do
  let!(:company) { create :company }
  let(:leader) { create :user }
  let(:parent) { create :parent_team }
  let(:child) { create :child_team, parent: parent, leader: leader }
  let!(:user) { create :user, team: child }
  let(:time_period) { create :time_period }
  let(:forecast) { Forecast.new(company, company.teams.roots(true), time_period.start_date, time_period.end_date) }

  it 'returns all root teams and nested teams and members' do
    json = ForecastSerializer.new(forecast, root: false).to_json
    json = JSON.parse(json)

    expect(json['teams'].length).to eq(1)
    expect(json['teams'][0]['teams'].length).to eq(1)
    expect(json['teams'][0]['teams'][0]['members'].length).to eq(1)
    expect(json['weighted_pipeline']).to eq(0)
  end
end
