require 'rails_helper'

RSpec.describe AsanaConnect, type: :model do
  describe '#self.url' do
    it 'returns URL per config' do
      expect(AsanaConnect.url 6).to eq "https://app.asana.com/-/oauth_authorize?client_id=375452637132320&redirect_uri=https%3A%2F%2Flocalhost%3A9292%2Fapi%2Fasana_connect%2Fcallback&response_type=code&state=6"
    end
  end
end
