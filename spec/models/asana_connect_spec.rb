require 'rails_helper'

describe AsanaConnect do
  describe '#self.url' do
    it 'returns URL per config' do
      stub_const('ASANA_CONNECT', asana_connect_hash)

      expect(AsanaConnect.url 6).to eq 'https://app.asana.com/-/oauth_authorize?client_id=375452637132320&redirect_uri=https%3A%2F%2Flocalhost%3A9292%2Fapi%2Fasana_connect%2Fcallback&response_type=code&state=6'
    end
  end

  private

  def asana_connect_hash
    OpenStruct.new({
      client_id: '375452637132320',
      client_secret: '618afc357fa2992463ab89a552ba8818',
      redirect_uri: 'https://localhost:9292/api/asana_connect/callback',
      authorize_url: 'https://app.asana.com/-/oauth_authorize',
      token_url: 'https://app.asana.com/-/oauth_token',
      site: 'https://localhost:9292/'
    })
  end
end
