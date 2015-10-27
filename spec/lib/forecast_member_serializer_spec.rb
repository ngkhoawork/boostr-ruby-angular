require 'rails_helper'

RSpec.describe ForecastMemberSerializer do
  let(:company) { create :company }
  let(:parent) { create :parent_team, company: company }
  let(:child) { create :child_team, company: company, parent: parent }
  let(:user) { create :user, company: company, team: child }
  let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
  let(:forecast) { ForecastMember.new(user, time_period) }
  let(:client) { create :client, company: company }

  it "serializes something" do
    json = ForecastMemberSerializer.new(forecast, root: false).to_json
    json = JSON.parse(json)

    expect(json['name']).to be
    expect(json['percent_to_quota']).to eq(100)
    expect(json['type']).to eq('member')
  end
end
