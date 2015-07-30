require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  let(:company) { create :company }
  let!(:user) { create :user, company: company }
  let!(:other_user) { create :user }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of users' do
      create_list :user, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(4)
      expect(response_json[0]['name']).to_not be_nil
    end
  end
end
