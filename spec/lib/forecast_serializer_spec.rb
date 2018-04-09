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
    object = ForecastSerializer.new(forecast, root: false).object

    expect(object.teams.length).to eq(1)
    expect(object.teams[0].teams.length).to eq(1)
    expect(object.teams[0].teams[0].members.length).to eq(1)
    expect(object.weighted_pipeline).to eq(0)
  end
end
