require 'rails_helper'

RSpec.describe Api::V2::ContactsController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:team) { create :parent_team }
  let(:user) { create :user, team: team }
  let(:team_user) { create :user, team: team }
  let(:client) { create :client, created_by: user.id }
  let(:client2) { create :client }
  let(:team_client) { create :client, created_by: team_user.id }
  let(:address_params) { attributes_for :address }
  let(:contact_params) { attributes_for(:contact, client_id: client.id, address_attributes: address_params) }

  before do
    valid_token_auth user
  end

  describe "GET #index" do
    let!(:contacts) { create_list :contact, 15, company: user.company }
    let!(:client_contacts) { create_list :contact, 5, company: user.company, clients: [client] }
    let!(:team_contacts) { create_list :contact, 7, company: user.company, clients: [team_client] }

    it 'returns a list of contacts' do
      get :index

      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      expect(json_response.length).to be 20
    end

    it 'accepts limit parameter' do
      limit = 10
      get :index, per: limit

      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      expect(json_response.length).to eq(limit)
    end

    it 'accepts page parameter' do
      limit = 10

      get :index, per: limit, page: 2

      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      expect(json_response.length).to eq(limit)
    end

    context 'filters' do
      it 'returns contacts assigned to client where user is on client\'s team' do
        get :index, filter: 'my_contacts'

        expect(response).to be_success
        expect(response.headers['X-Total-Count']).to eq(client_contacts.count.to_s)
        expect(json_response.length).to eq(client_contacts.count)
      end

      it 'returns contacts assigned to clients where user\'s team members are on client\'s team' do
        get :index, filter: 'team'

        expect(response).to be_success

        team_contacts_count = team_contacts.count + client.contacts.count

        expect(response.headers['X-Total-Count']).to eq(team_contacts_count.to_s)
        expect(json_response.length).to eq(team_contacts_count)
      end
    end
  end

  describe "POST #create" do
    it 'creates a new contact and returns success' do
      expect{
        post :create, contact: contact_params

        expect(response).to be_success
        expect(json_response['created_by']).to eq(user.id)
      }.to change(Contact, :count).by(1)
    end

    it 'returns errors if the contact is invalid' do
      expect{
        post :create, contact: { addresses_attributes: address_params }

        expect(response.status).to eq(422)
        expect(json_response['errors']['primary account']).to eq(["can't be blank"])
      }.to_not change(Contact, :count)
    end
  end

  describe "PUT #update" do
    let(:contact) { create :contact, clients: [client] }

    it 'updates a contact successfully' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }

      expect(response).to be_success
      expect(json_response['name']).to eq('New Name')
    end

    it 'sets the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }

      expect(response).to be_success
      expect(json_response['primary_client_json']['name']).to eq(client.name)
    end

    it 'updates the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }

      expect(response).to be_success
      expect(json_response['primary_client_json']['name']).to eq(client.name)

      put :update, id: contact.id, contact: { name: 'New Name', client_id: client2.id, set_primary_client: true }
      expect(response).to be_success
      expect(json_response['primary_client_json']['name']).to eq(client2.name)
    end
  end

  describe "DELETE #destroy" do
    let!(:contact) { create :contact, clients: [client] }

    it 'marks the contact as deleted' do
      delete :destroy, id: contact.id

      expect(response).to be_success
      expect(contact.reload.deleted_at).to_not be_nil
    end
  end
end
