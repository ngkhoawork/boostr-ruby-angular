require 'rails_helper'

RSpec.describe Quota, type: :model do

  context 'scopes' do
    context 'for_time_period' do
      let!(:user) { create :user }
      let!(:time_period) { create :time_period }
      let!(:other_time_period) { create :time_period, start_date: time_period.end_date + 1.month, end_date: time_period.end_date + 2.months }

      it 'returns the quotas scoped to the given time period id' do
        expect(Quota.count).to eq(2)
        expect(Quota.for_time_period(time_period.start_date, time_period.end_date).length).to eq(1)
      end
    end
  end

end
