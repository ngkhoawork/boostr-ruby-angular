require 'rails_helper'

RSpec.describe ForecastMember do
  context 'as_json' do
    let(:company) { create :company }
    let(:parent) { create :parent_team, company: company }
    let(:child) { create :child_team, company: company, parent: parent }
    let(:user) { create :user, company: company, team: child }
    let(:time_period) { create :time_period, company: company, start_date: "2015-01-01", end_date: "2015-12-31" }
    let(:forecast) { ForecastMember.new(user, time_period) }

    it 'returns the revenue for a member that has no revenue' do
      expect(forecast.revenue).to eq(0)
    end

    context 'with revenue' do
      let(:client) { create :client, company: company }

      it 'sums the revenue' do
        client.client_members.create(user: user, share: 100, role: 'Member')
        today = Time.parse("2015-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(10000)
      end

      it 'sums the split revenue' do
        another_user = create(:user, company: company, team: child)
        client.client_members.create(user: user, share: 50, role: 'Member')
        client.client_members.create(user: another_user, share: 50, role: 'Member')
        today = Time.parse("2015-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(5000)
      end

      it 'does not sum revenue outside of the time period' do
        client.client_members.create(user: user, share: 100, role: 'Member')
        today = Time.parse("2013-09-17")
        revenues = create_list :revenue, 10, company: company, client: client, user: user, budget: 1000, start_date: today, end_date: today
        expect(forecast.revenue).to eq(0)
      end
    end
  end
end
