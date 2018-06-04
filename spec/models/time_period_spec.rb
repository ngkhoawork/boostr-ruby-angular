require 'rails_helper'

RSpec.describe TimePeriod, type: :model do
  let!(:company) { create :company }

  after(:all) do
    Timecop.return
  end

  context 'scopes' do
    let!(:time_period) { create :time_period }

    context 'now' do
      it 'returns the first time period that encompasses the current date' do
        new_time = Time.local(2015, 1, 2, 0, 0, 0)
        Timecop.freeze(new_time)
        expect(TimePeriod.now).to eq(time_period)
        Timecop.return
      end

      it 'returns nil when there are no current time_periods' do
        new_time = Time.local(2015, 9, 25, 0, 0, 0)
        Timecop.freeze(new_time)
        expect(TimePeriod.now).to eq(nil)
        Timecop.return
      end
    end
  end

  context 'validating' do
    let(:time_period) { create :time_period }

    it "ignores itself" do
      expect(build(:time_period)).to be_valid
    end

    it "is case insensitive" do
      time_period
      another_time_period = build(:time_period, name: time_period.name.downcase)
      expect(another_time_period).to be_invalid
    end

    it 'validates the name uniqueness' do
      time_period
      another_time_period = build(:time_period, name: time_period.name)
      expect(another_time_period).to_not be_valid
      expect(another_time_period.errors[:name]).to be_present
    end

    it 'ignores duplicates from other companies' do
      time_period
      another_company = create(:company)
      another_time_period = build(:time_period, company: another_company, name: time_period.name)
      expect(another_time_period).to be_valid
    end

    it 'ignores deleted time periods' do
      time_period.destroy
      another_time_period = build(:time_period, name: time_period.name)
      expect(another_time_period).to be_valid
     end
  end
end
