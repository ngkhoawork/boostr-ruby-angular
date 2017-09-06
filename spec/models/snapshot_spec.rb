require 'rails_helper'

RSpec.describe Snapshot, type: :model do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:time_period) { create :time_period, company: company }

  context 'scopes' do
    context 'two_recent' do

      it 'returns that last two most recent snapshots' do
        allow_any_instance_of(ForecastMember).to receive(:weighted_pipeline).and_return(0)
        allow_any_instance_of(ForecastMember).to receive(:revenue).and_return(0)

        snapshot_one = create :snapshot, company: company, user: user, time_period: time_period, created_at: (DateTime.now - 1.day)
        snapshot_two = create :snapshot, company: company, user: user, time_period: time_period, created_at: (DateTime.now - 1.hour)
        snapshot_three = create :snapshot, company: company, user: user, time_period: time_period, created_at: (DateTime.now - 10.minutes)

        expect(Snapshot.all.length).to eq(3)
        expect(Snapshot.two_recent_for_time_period(time_period.start_date, time_period.end_date).length).to eq(2)
        expect(Snapshot.two_recent_for_time_period(time_period.start_date, time_period.end_date)).to include(snapshot_two)
        expect(Snapshot.two_recent_for_time_period(time_period.start_date, time_period.end_date)).to include(snapshot_three)
      end
    end
  end

  context 'lifecycle hooks' do
    let(:snapshot) { create :snapshot, company: company, user: user, time_period: time_period }

    before do
      allow_any_instance_of(ForecastMember).to receive(:weighted_pipeline).and_return(100)
      allow_any_instance_of(ForecastMember).to receive(:revenue).and_return(200)
    end

    it 'takes a snapshot of weighted pipeline and revenue for the user and time period' do
      expect(snapshot.weighted_pipeline).to eq(100)
      expect(snapshot.revenue).to eq(200)
    end
  end
end
