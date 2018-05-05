require 'rails_helper'

describe Api::CustomValuesController do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of settings' do
      get :index, format: :json

      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json.length).to eq(9)
    end
  end
end
