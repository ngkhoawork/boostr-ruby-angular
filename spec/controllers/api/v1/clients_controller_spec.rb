require 'rails_helper'

describe Api::V1::ClientsController do
  let!(:company) { create :company, :fast_create_company }
  let(:team) { create :parent_team }
  let(:user) { create :user, team: team }
  let(:address_params) { attributes_for :address }
  let(:client_params) { attributes_for(:client, address_attributes: address_params, client_type_id: client_type_id(company), company: company) }

  before do
    valid_token_auth user
  end

  describe "GET #index" do
    let!(:leader_client) { create :client, parent_client: nil }

    let!(:user_client) { create :client, created_by: user.id, parent_client: nil }

    let(:another_user) { create :user, team: team }
    let!(:team_client) { create :client, created_by: another_user.id, parent_client: nil }

    before do
      create_list :client, 30, created_by: user.id, parent_client: nil
    end

    it 'returns a list of clients in csv' do
      get :index, format: :csv

      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it 'returns a paginated list of clients for the current_user' do
      get :index

      expect(response).to be_success
      expect(json_response.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("31")
    end

    it 'returns a list of the clients for the current_user team' do
      get :index, filter: 'team'

      expect(response).to be_success
      expect(json_response.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("32")
    end

    it 'returns a list of clients for the current_user company if they are a leader' do
      team.update_attributes(leader: user)

      get :index, filter: 'company'

      expect(response).to be_success
      expect(json_response.length).to eq(10)
      expect(response.headers['X-Total-Count']).to eq("33")
    end

    context 'client_type_id is specified' do
      before do
        create :client, created_by: user.id, client_type_id: 1, name: 'Boostr'
      end

      it 'returns a paginated list of clients by type if client_type_id is specified' do
        get :index, client_type_id: 1

        expect(response).to be_success
        expect(json_response.length).to eq(1)
        expect(response.headers['X-Total-Count']).to eq("1")
      end

      it 'searches clients and filters by type id' do
        get :index, client_type_id: 1, name: 'Boos'

        expect(response).to be_success
        expect(json_response.length).to eq(1)
        expect(response.headers['X-Total-Count']).to eq("1")
      end
    end
  end

  describe "POST #create" do
    it 'creates a new client and returns success' do
      expect{
        post :create, client: client_params

        expect(response).to be_success
      }.to change(Client, :count).by(1)
    end

    it 'returns errors if the client is invalid' do
      expect{
        post :create, client: { addresses_attributes: address_params }

        expect(response.status).to eq(422)
        expect(json_response['errors']['name']).to eq(["Name can't be blank"])
      }.to_not change(Client, :count)
    end
  end

  describe 'GET #show' do
    let(:client) { create :client, created_by: user.id }

    it 'returns json for a client' do
      get :show, id: client.id

      expect(response).to be_success
    end
  end

  describe "PUT #update" do
    let(:client) { create :client, created_by: user.id  }

    it 'updates a client successfully' do
      put :update, id: client.id, client: { name: 'New Name' }

      expect(response).to be_success
      expect(json_response['name']).to eq('New Name')
    end
  end

  describe "DELETE #destroy" do
    let!(:client) { create :client, created_by: user.id  }

    it 'marks the client as deleted' do
      delete :destroy, id: client.id

      expect(response).to be_success
      expect(client.reload.deleted_at).to_not be_nil
    end
  end

  def client_type_id(company)
    company.fields.find_by(name: 'Client Type').options.ids.sample
  end
end
