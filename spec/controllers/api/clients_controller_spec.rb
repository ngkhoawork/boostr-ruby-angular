require 'rails_helper'

RSpec.describe Api::ClientsController, type: :controller do

  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:address_params) { attributes_for :address }
  let(:client_params) { attributes_for(:client, address_attributes: address_params) }

  before do
    sign_in user
  end

  describe "GET #index" do
    let!(:leader_client) { create :client, company: company }

    let!(:user_client) { create :client, company: company, created_by: user.id }

    let(:another_user) { create :user, company: company, team: team }
    let!(:team_client) { create :client, company: company, created_by: another_user.id }

    before do
      30.times do
        create :client, company: company, created_by: user.id
      end
    end

    it 'returns a list of clients in csv' do
      get :index, format: :csv
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it 'returns a paginated list of clients for the current_user' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("31")
    end

    it 'returns a list of the clients for the current_user team' do
      get :index, filter: 'team', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("32")
    end

    it 'returns a list of clients for the current_user company if they are a leader' do
      team.update_attributes(leader: user)

      get :index, filter: 'company', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("33")
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

  describe 'GET #show' do
    let(:client) { create :client, company: company, created_by: user.id }

    it 'returns json for a client' do
      get :show, id: client.id, format: :json
      expect(response).to be_success
    end
  end

  describe "PUT #update" do
    let(:client) { create :client, company: company, created_by: user.id  }

    it 'updates a client successfully' do
      put :update, id: client.id, client: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end

  describe "DELETE #destroy" do
    let!(:client) { create :client, company: company, created_by: user.id  }

    it 'marks the client as deleted' do
      delete :destroy, id: client.id, format: :json
      expect(response).to be_success
      expect(client.reload.deleted_at).to_not be_nil
    end
  end
end
