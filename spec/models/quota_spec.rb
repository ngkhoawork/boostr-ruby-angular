require 'rails_helper'

RSpec.describe Quota, type: :model do

  context 'scopes' do
    context 'for_time_period' do
      let(:company) { create :company }
      let!(:user) { create :user, company: company }
      let!(:time_period) { create :time_period, company: company }
      let!(:other_time_period) { create :time_period, company: company }

      it 'returns all quotas when the time period id is nil' do
        expect(Quota.for_time_period(nil).length).to eq(2)
      end

      it 'returns the quotas scoped to the given time period id' do
        expect(Quota.count).to eq(2)
        expect(Quota.for_time_period(time_period.id).length).to eq(1)
      end
    end
  end

end
