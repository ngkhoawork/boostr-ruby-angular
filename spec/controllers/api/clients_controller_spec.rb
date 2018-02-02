require 'rails_helper'

RSpec.describe Api::ClientsController, type: :controller do

  let(:company) { Company.first }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, team: team }
  let(:address_params) { attributes_for :address }
  let(:client_params) { attributes_for(:client, address_attributes: address_params, client_type_id: client_type_id(company), company: company) }

  before do
    sign_in user
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

    context 'client_type_id is specified' do
      before do
        create :client, created_by: user.id, client_type_id: 1, name: 'Boostr'
      end

      it 'returns a paginated list of clients by type if client_type_id is specified' do
        get :index, client_type_id: 1, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(1)
        expect(response.headers['X-Total-Count']).to eq("1")
      end

      it 'searches clients and filters by type id' do
        get :index, client_type_id: 1, name: 'Boos', format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(1)
        expect(response.headers['X-Total-Count']).to eq("1")
      end
    end
  end

  describe 'GET #search_clients' do
    it 'searches clients and filters by type id' do
      client(name: 'Boostr', created_by: user.id, client_type_id: 1)

      get :search_clients, client_type_id: 1, name: 'Boos', format: :json

      expect(response).to be_success

      expect(json_response.length).to eq(1)
      expect(json_response.first['name']).to eq 'Boostr'
    end
  end

  describe "POST #create" do
    it 'creates a new client and returns success' do
      expect{
        post :create, client: client_params, format: :json

        expect(response).to be_success
        expect(json_response['company_id']).to eq(company.id)
        expect(json_response['created_by']).to eq(user.id)
      }.to change(Client, :count).by(1)
    end

    it 'returns errors if the client is invalid' do
      expect{
        post :create, client: { addresses_attributes: address_params }, format: :json

        expect(response.status).to eq(422)
        expect(json_response['errors']['name']).to eq(['Name can\'t be blank'])
      }.to_not change(Client, :count)
    end

    it 'map lead to contact' do
      post :create, client: client_params, lead_id: lead.id

      expect(Client.last.leads).to include lead
    end
  end

  describe 'GET #show' do
    it 'returns json for a client' do
      client(created_by: user.id)

      get :show, id: client.id, format: :json

      expect(response).to be_success
    end
  end

  describe 'GET #filter_options' do
    it 'returns json for a client' do
      client(created_by: user.id)
      client_member(user: user, client: client)

      get :filter_options, format: :json
      expect(response).to be_success
      expect(json_response['owners'].first).to eq({'id' => user.id, 'name' => user.name})
      expect(json_response['cities']).to eq [client.address.city]
    end

    it 'rejects blank city' do
      client.address.update(city: ' ')

      get :filter_options, format: :json
      expect(json_response['cities']).to be_empty
    end

    it 'rejects empty city' do
      client.address.update(city: nil)

      get :filter_options, format: :json
      expect(json_response['cities']).to be_empty
    end
  end

  describe "PUT #update" do
    it 'updates a client successfully' do
      client(created_by: user.id)

      put :update, id: client.id, client: { name: 'New Name' }, format: :json

      expect(response).to be_success
      expect(json_response['name']).to eq('New Name')
    end
  end

  describe "DELETE #destroy" do
    let!(:client) { create :client, created_by: user.id }
    let!(:client_with_associations) { create :client, created_by: user.id }
    let!(:contact) { create :contact, client: client_with_associations}

    it 'marks the client as deleted' do
      delete :destroy, id: client.id, format: :json
      expect(response).to be_success
      expect(client.reload.deleted_at).to_not be_nil
    end

    it 'returns error if client has related associations' do
      delete :destroy, id: client_with_associations.id, format: :json
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['error']).to include('Contact')
    end
  end

  private

  def client_type_id(company)
    company.fields.find_by(name: 'Client Type').options.ids.sample
  end

  def client(opts={})
    @_client ||= create :client, opts
  end

  def client_member(opts={})
    @_client_member ||= create :client_member, opts
  end

  def lead
    @_lead ||= create :lead, company: company
  end
end
