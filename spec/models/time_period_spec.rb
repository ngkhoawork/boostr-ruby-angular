require 'rails_helper'

RSpec.describe TimePeriod, type: :model do
  let(:company) { create :company }

  context 'quotas' do
    it 'should create a quota for each user of the company' do
      create_list :user, 2, company: company
      expect {
        create :time_period, company: company
      }.to change(Quota, :count).by(2)
    end
  end
end
