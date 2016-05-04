require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe '#add_activity' do
    let(:company) { create :company }
    let(:client) { create :client, company: company }
    let(:contact) { create :contact, company: company, client: client }
    let(:deal) { create :deal, company: company, advertiser: client }
    let(:user) { create :user, company: company }
    let(:activity) { create :activity, deal: deal, contact: contact, user: user, happened_at: Date.new(2016, 3, 31), company: company }

    it 'return activitiy date' do
      expect(activity.happened_at).to eq(Date.new(2016, 3, 31))
    end
  end
end
