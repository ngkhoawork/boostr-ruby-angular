require 'rails_helper'

RSpec.describe Api::ClientTypesController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client_type_params) { attributes_for(:client_type) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'returns a list of client_types in json' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(2)
    end

    it 'returns a list of client_types in csv' do
      get :index, format: :csv
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end
  end

  describe "POST #create" do
    it 'creates a new client_type and returns success' do
      expect{
        post :create, client_type: client_type_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['company_id']).to eq(company.id)
      }.to change(ClientType, :count).by(1)
    end

    it 'returns errors if the client_type is invalid' do
      expect{
        post :create, client_type: { name: '' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      }.to_not change(ClientType, :count)
    end
  end

  describe "PUT #update" do
    let(:client_type) { create :client_type, company: company }

    it 'updates a client_type successfully' do
      put :update, id: client_type.id, client_type: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end

  describe "DELETE #destroy" do
    let!(:client_type) { create :client_type, company: company }

    it 'marks the client_type as deleted' do
      delete :destroy, id: client_type.id, format: :json
      expect(response).to be_success
      expect(client_type.reload.deleted_at).to_not be_nil
    end
  end
end
