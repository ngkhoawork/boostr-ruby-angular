require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client) { create :client, company: company }
  let(:client2) { create :client }
  let(:address_params) { attributes_for :address }
  let(:contact_params) { attributes_for(:contact, client_id: client.id, address_attributes: address_params) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'returns a list of contacts' do
      create_list :contact, 3, company: company, clients: [client]

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
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
        post :create, contact: { addresses_attributes: address_params }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      }.to_not change(Contact, :count)
    end
  end

  describe "PUT #update" do
    let(:contact) { create :contact, company: company, clients: [client] }

    it 'updates a contact successfully' do
      put :update, id: contact.id, contact: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end

    it 'sets the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client']['name']).to eq(client.name)
    end

    it 'updates the primary contact' do
      put :update, id: contact.id, contact: { name: 'New Name', client_id: client.id }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client']['name']).to eq(client.name)

      put :update, id: contact.id, contact: { name: 'New Name', client_id: client2.id, set_primary_client: true }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['primary_client']['name']).to eq(client2.name)
    end
  end

  describe "DELETE #destroy" do
    let!(:contact) { create :contact, company: company, clients: [client] }

    it 'marks the contact as deleted' do
      delete :destroy, id: contact.id, format: :json
      expect(response).to be_success
      expect(contact.reload.deleted_at).to_not be_nil
    end
  end

end
