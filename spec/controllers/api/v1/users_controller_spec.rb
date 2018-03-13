require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:company) { create :company }
  let!(:user) { create :user }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns a list of users' do
      create_list :user, 3

      get :index

      expect(response).to be_success
      expect(json_response.length).to eq(4)
      expect(json_response[0]['name']).to_not be_nil
    end
  end

  describe 'PUT #update' do
    let(:new_user) { create :user }

    it 'updates a user successfully' do
      put :update, id: new_user.id, user: { first_name: 'New', last_name: 'Name', title: 'Boss' }

      expect(response).to be_success
      expect(json_response['first_name']).to eq('New')
      expect(json_response['last_name']).to eq('Name')
      expect(json_response['title']).to eq('Boss')
    end

    it 'does not allow user to disable itself' do
      put :update, id: user.id, user: { is_active: false }

      expect(response).to be_success
      expect(json_response['is_active']).to be(true)
    end
  end
end
