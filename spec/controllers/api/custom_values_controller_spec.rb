require 'rails_helper'

RSpec.describe Api::CustomValuesController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of settings' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(5)
    end
  end
end