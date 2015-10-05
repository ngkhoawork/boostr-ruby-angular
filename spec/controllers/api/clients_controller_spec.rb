require 'rails_helper'

RSpec.describe Api::ClientsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:address_params) { attributes_for :address }
  let(:client_params) { attributes_for(:client, address_attributes: address_params) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'returns a list of clients in json' do
      create_list :client, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end

    it 'returns a list of clients in csv' do
      create_list :client, 3, company: company

      get :index, format: :csv
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end
  end

  describe "POST #create" do
    it 'creates a new client and returns success' do
      expect{
        post :create, client: client_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['company_id']).to eq(company.id)
        expect(response_json['created_by']).to eq(user.id)
      }.to change(Client, :count).by(1)
    end

    it 'returns errors if the client is invalid' do
      expect{
        post :create, client: { addresses_attributes: address_params }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      }.to_not change(Client, :count)
    end
  end

  describe "PUT #update" do
    let(:client) { create :client, company: company }

    it 'updates a client successfully' do
      put :update, id: client.id, client: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end

  describe "DELETE #destroy" do
    let!(:client) { create :client, company: company }

    it 'marks the client as deleted' do
      delete :destroy, id: client.id, format: :json
      expect(response).to be_success
      expect(client.reload.deleted_at).to_not be_nil
    end
  end
end
