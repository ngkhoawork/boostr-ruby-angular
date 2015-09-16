require 'rails_helper'

RSpec.describe TimePeriod, type: :model do
  let(:company) { create :company }
  let(:time_period) { create :time_period, company: company }

  context 'validating' do
    it "ignores itself" do
      time_period.save
      expect(time_period).to be_valid
    end

    it "is case insensitive" do
      time_period
      another_time_period = build(:time_period, company: company, name: time_period.name.downcase)
      expect(another_time_period).to be_invalid
    end

    it 'validates the name uniqueness' do
      time_period
      another_time_period = build(:time_period, company: company, name: time_period.name)
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
      another_time_period = build(:time_period, company: company, name: time_period.name)
      expect(another_time_period).to be_valid
     end
  end

  context 'quotas' do
    it 'should create a quota for each user of the company' do
      create_list :user, 2, company: company
      expect {
        create :time_period, company: company
      }.to change(Quota, :count).by(2)
    end
  end
end
