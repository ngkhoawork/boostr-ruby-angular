require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe '#add_activity' do
    let(:company) { create :company }
    let(:client) { create :client, company: company }
    let(:deal) { create :deal, company: company, advertiser: client }
    let(:activity) { create :activity, deal: deal, happened_at: Date.new(2016, 3, 31), company: company }

    it 'return activitiy date' do
      expect(activity.happened_at).to eq(Date.new(2016, 3, 31))
    end
  end
end
