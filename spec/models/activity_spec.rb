require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe '#add_activity' do
    let(:company) { create :company }
    let(:activity) { create :activity, happened_at: Date.new(2016, 3, 31), company: company }
    let!(:client) { create :client, company: company }
    let!(:deal) { create_list :deal, 2, company: company, advertiser: client }

    it 'return activitiy date' do
      expect(activity.happened_at).to eq(Date.new(2016, 3, 31))
    end
  end
end
