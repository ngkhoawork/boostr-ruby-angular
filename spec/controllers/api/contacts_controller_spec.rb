require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do
  let(:team) { create :parent_team }
  let(:user) { create :user, team: team }
  let(:team_user) { create :user, team: team }
  let(:client) { create :client, created_by: user.id }
  let(:client2) { create :client }
  let(:team_client) { create :client, created_by: team_user.id }
  let(:address_params) { attributes_for :address }
  let(:contact_params) { attributes_for(:contact, client_id: client.id, address_attributes: address_params) }

  before do
    sign_in user
  end

  describe "GET #index" do
    let!(:contacts) { create_list :contact, 15, company: user.company, created_by: user.id }
    let!(:client_contacts) { create_list :contact, 5, company: user.company, clients: [client] }
    let!(:team_contacts) { create_list :contact, 7, company: user.company, clients: [team_client] }

    it 'returns a list of contacts' do
      get :index, format: :json

      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      expect(json_response.length).to be 20
    end

    it 'accepts limit parameter' do
      limit = 10
      get :index, per: limit, format: :json
      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(limit)
    end

    it 'accepts page parameter' do
      limit = 10
      get :index, per: limit, page: 2, format: :json
      expect(response).to be_success
      expect(response.headers['X-Total-Count']).to eq(user.company.contacts.count.to_s)
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(limit)
    end

    it 'lists unassigned contacts' do
      get :index, unassigned: 'yes', format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq 15
    end

    context 'filters' do
      it 'returns contacts assigned to client where user is on client\'s team' do
        get :index, filter: 'my_contacts', format: :json
        expect(response).to be_success
        expect(response.headers['X-Total-Count']).to eq(client_contacts.count.to_s)
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(client_contacts.count)
      end

      it 'returns contacts assigned to clients where user\'s team members are on client\'s team' do
        get :index, filter: 'team', format: :json
        expect(response).to be_success
        team_contacts_count = team_contacts.count + client.contacts.count
        expect(response.headers['X-Total-Count']).to eq(team_contacts_count.to_s)
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(team_contacts_count)
      end
    end
  end

  describe "POST #create" do
    it 'creates a new contact and returns success' do
      expect{
        post :create, contact: contact_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['created_by']).to eq(user.id)
      }.to change(Contact, :count).by(1)
    end

    it 'returns errors if the contact is invalid' do
      expect{
        post :create, contact: { client_id: client2.id, addresses_attributes: address_params }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['primary account']).to eq(["can't be blank"])
      }.to_not change(Contact, :count)
    end
  end

  describe "PUT #update" do
    let(:contact) { create :contact, clients: [client], client_id: client.id }

    it 'updates a contact successfully' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json
      expect(response).to be_success

      expect(response_json(response)['name']).to eq('New Name')
    end

    it 'lists contact clients' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json

      expect(response_json(response)['clients'].length).to be 1
    end

    it 'sets the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client_json']['name']).to eq(client.name)
    end

    it 'updates the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client_json']['name']).to eq(client.name)

      put :update, id: contact.id, contact: { name: 'New Name', client_id: client2.id, set_primary_client: true }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client_json']['name']).to eq(client2.name)
    end
  end

  describe "DELETE #destroy" do
    let!(:contact) { create :contact, clients: [client] }

    it 'marks the contact as deleted' do
      delete :destroy, id: contact.id, format: :json
      expect(response).to be_success
      expect(contact.reload.deleted_at).to_not be_nil
    end
  end

end
