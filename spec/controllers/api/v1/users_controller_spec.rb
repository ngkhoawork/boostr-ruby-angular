require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:company) { Company.first }
  let!(:user) { create :user }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns a list of users' do
      create_list :user, 3

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(4)
      expect(response_json[0]['name']).to_not be_nil
    end
  end

  describe 'PUT #update' do
    let(:new_user) { create :user }

    it 'updates a user successfully' do
      put :update, id: new_user.id, user: { first_name: 'New', last_name: 'Name', title: 'Boss' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['first_name']).to eq('New')
      expect(response_json['last_name']).to eq('Name')
      expect(response_json['title']).to eq('Boss')
    end

    it 'does not allow user to disable itself' do
      put :update, id: user.id, user: { is_active: false }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['is_active']).to be(true)
    end
  end
end
