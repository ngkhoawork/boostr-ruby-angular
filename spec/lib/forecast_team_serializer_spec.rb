require 'rails_helper'

RSpec.describe ForecastTeamSerializer do
  let!(:company) { create :company }
  let(:leader) { create :user, company: company }
  let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
  let(:client) { create :client, company: company }
  let(:team) { create :parent_team, company: company, parent: parent_team }
  let(:member) { create :user, company: company, team: team }
  let(:parent_parent_team) { create :parent_team, company: company }
  let(:parent_team) { create :parent_team, company: company, parent: parent_parent_team }
  let(:forecast) { ForecastTeam.new(team, time_period.start_date, time_period.end_date) }
  let!(:leader_quota) { create :quota, user: leader, value: 5000, time_period: time_period, company: company }
  let!(:member_quota) { create :quota, user: member, value: 2000, time_period: time_period, company: company }

  it "serializes something" do
    object = ForecastTeamSerializer.new(forecast, root: false, cache: false).object

    expect(object.name).to be
    expect(object.teams).to eq([])
    expect(object.parents.length).to eq(2)
    expect(object.members.length).to eq(1)
    expect(object.type).to eq('team')
  end
end
