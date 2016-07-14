require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe '#add_activity' do
    let(:client) { create :client }
    let(:deal) { create :deal, advertiser: client }
    let(:user) { create :user }
    let(:activity) { create :activity, deal: deal, user: user, happened_at: Date.new(2016, 3, 31) }

    it 'return activity date' do
      expect(activity.happened_at).to eq(Date.new(2016, 3, 31))
    end
  end
end
