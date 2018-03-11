require 'rails_helper'

RSpec.describe Api::V2::ClientMembersController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:client) { create :client, company: company }
  let(:user) { create :user, company: company }
  let(:client_member_params) { attributes_for :client_member, user_id: user.id, values_attributes: [create_member_role(company).attributes] }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    let!(:client_member) { create :client_member, client_id: client.id, user_id: user.id, values: [create_member_role(company)] }
    it 'returns a list of client_members' do
      get :index, client_id: client.id

      expect(response).to be_success
      expect(json_response.length).to eq(1)
    end
  end

  describe 'POST #create' do
    it 'creates a new client_member and returns success' do
      expect do
        post :create, client_id: client.id, client_member: client_member_params

        expect(response).to be_success
        expect(json_response['user_id']).to eq(user.id)
        expect(json_response['client_id']).to eq(client.id)
      end.to change(ClientMember, :count).by(1)
    end

    it 'returns errors if the client_member is invalid' do
      expect do
        post :create, client_id: client.id, client_member: { bad: 'param' }

        expect(response.status).to eq(422)
        expect(json_response['errors']['share']).to eq(["can't be blank"])
      end.to_not change(ClientMember, :count)
    end
  end

  describe 'PUT #update' do
    let!(:client_member) { create :client_member, client_id: client.id, user_id: user.id, values: [create_member_role(company)] }

    it 'updates a client_member successfully' do
      put :update, id: client_member.id, client_id: client.id, client_member: { share: '62' }

      expect(response).to be_success
      expect(json_response['share']).to eq(62)
    end
  end
end
