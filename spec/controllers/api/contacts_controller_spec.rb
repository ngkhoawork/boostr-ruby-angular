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

    context 'search criterions' do
      it 'filters by workplace' do
        client_criteria = create :client, name: 'Flipboard', company: user.company, created_by: user.id
        create :contact, company: user.company, clients: [client_criteria], client_id: client_criteria.id

        get :index, filter: 'my_contacts', workplace: 'flipboard', format: :json

        expect(json_response.length).to be 1
        expect(json_response.first['primary_client_json']['name']).to eql 'Flipboard'
      end

      it 'filters by city' do
        address_criteria = attributes_for :address, city: 'Palm Beach'
        user_client = create :client, company: user.company, created_by: user.id
        create :contact, company: user.company, address_attributes: address_criteria, created_by: user.id, clients: [user_client]

        get :index, filter: 'my_contacts', city: 'palm beach', format: :json

        expect(json_response.length).to be 1
        expect(json_response.first['address']['city']).to eql 'Palm Beach'
      end

      it 'filters by contact job level' do
        field = user.company.fields.find_by(subject_type: 'Contact', name: 'Job Level')
        ceo_option = create :option, name: 'CEO', field: field
        seller_option = create :option, name: 'Seller', field: field

        user_client = create :client, company: user.company, created_by: user.id
        ceo_contact = create :contact, company: user.company,
          created_by: user.id, clients: [user_client],
          values_attributes: [field: field, option: ceo_option]
        seller_contact = create :contact, company: user.company,
          created_by: user.id, clients: [user_client],
          values_attributes: [field: field, option: seller_option]

        get :index, filter: 'my_contacts', job_level: 'CEO', format: :json

        expect(json_response.length).to be 1
        expect(json_response.first['name']).to eql ceo_contact.name
      end
    end
  end

  describe 'GET #show' do
    let!(:contact) { create :contact, clients: [client], name: 'Testy test' }

    it 'returns contact info' do
      get :show, id: contact.id

      expect(json_response['name']).to eql 'Testy test'
    end
  end

  describe "POST #create" do
    it 'creates a new contact and returns success' do

      expect{
        post :create, contact: contact_params, format: :json

        expect(response).to be_success
        expect(json_response['created_by']).to eq(user.id)
      }.to change(Contact, :count).by(1)
    end

    it 'returns errors if the contact is invalid' do
      expect{
        post :create, contact: { addresses_attributes: address_params }, format: :json
        expect(response.status).to eq(422)

        expect(json_response['errors']['primary account']).to eq(["can't be blank"])
      }.to_not change(Contact, :count)
    end

    it 'map lead to contact' do
      valid_contact_params = contact_params.merge(lead_id: lead.id)

      post :create, contact: valid_contact_params

      expect(Contact.last.lead).to eq lead
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

  describe 'GET #metadata' do
    it 'returns contacts metadata' do
      prepare_contact_metadata

      get :metadata, format: :json

      expect(json_response['workplaces']).to include 'Fliboard'
      expect(json_response['workplaces']).to include 'Fidelity'
      expect(json_response['job_levels']).to include 'CEO'
      expect(json_response['job_levels']).to include 'Seller'
      expect(json_response['cities']).to include 'Palm Beach'
      expect(json_response['cities']).to include 'New York'
      expect(json_response['countries']).to include 'Ukraine'
      expect(json_response['countries']).to include 'France'
    end
  end

  describe 'GET #related_clients' do
    it 'returns related clients information' do
      user_client = create :client, name: 'Fidelity', company: user.company, created_by: user.id, client_type_id: advertiser_type_id(user.company)
      user_client2 = create :client, name: 'Fliboard', company: user.company, created_by: user.id, client_type_id: advertiser_type_id(user.company)
      user_client3 = create :client, name: 'Test', company: user.company, created_by: user.id, client_type_id: agency_type_id(user.company)
      contact = create :contact, company: user.company, created_by: user.id, clients: [user_client, user_client2], client_id: user_client3.id

      get :related_clients, id: contact.id

      expect(json_response.map{|el| el['client']['name'] } ).to include 'Fidelity'
      expect(json_response.map{|el| el['client']['name'] } ).to include 'Fliboard'
    end
  end

  describe 'POST #assign_account' do
    it 'should assign client to contact' do
      contact = create :contact

      expect{
        post :assign_account, id: contact.id, client_id: client.id
      }.to change(ClientContact, :count).by(1)
    end
  end

  describe 'DELETE #unassign_account' do
    it 'should unassign client from contact' do
      contact = create :contact, clients: [client]

      expect{
        delete :unassign_account, id: contact.id, client_id: client.id
      }.to change(ClientContact, :count).by(-1)
    end
  end

  private

  def prepare_contact_metadata
    field = user.company.fields.find_by(subject_type: 'Contact')
    ceo_option = create :option, name: 'CEO', field: field
    seller_option = create :option, name: 'Seller', field: field

    user_client = create :client, name: 'Fidelity', company: user.company, created_by: user.id
    user_client2 = create :client, name: 'Fliboard', company: user.company, created_by: user.id

    ceo_contact = create :contact, company: user.company,
      created_by: user.id, clients: [user_client], client_id: user_client.id,
      values_attributes: [field: field, option: ceo_option],
      address_attributes: (attributes_for :address, city: 'Palm Beach')

    seller_contact = create :contact, company: user.company,
      created_by: user.id, clients: [user_client2], client_id: user_client2.id,
      values_attributes: [field: field, option: seller_option],
      address_attributes: (attributes_for :address, city: 'New York')

  end

  def lead
    @_lead ||= create :lead, company: company
  end

  def company
    @_company ||= create :company
  end
end
