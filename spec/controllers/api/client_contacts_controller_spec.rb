require 'rails_helper'

RSpec.describe Api::ClientContactsController, type: :controller do
  let!(:company) { create :company }

  let!(:job_level_field) do
    create :field, subject_type: 'Contact', name: 'Job Level', value_type: 'Option', locked: true
  end

  let(:client_type_id) { Field.where(company: company, name: "Client Type").first.options.first.id }
  let!(:client) { create :client, company: company, client_type_id: client_type_id }
  let!(:user) { create :user, company: company }
  let!(:agencies) { create_list :client, 3, company: company, client_type_id: client_type_id + 1 }
  let!(:contacts) { create_list :contact, 2, company: company, clients: [client] + agencies }
  let!(:irrelevant_contact) { create :contact, company: company, clients: agencies }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of related contacts' do
      get :index, client_id: client.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(2)
    end
  end

  describe 'GET #related_clients' do
    it 'returns a list of related clients through contacts' do
      get :related_clients, client_id: client.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
      expect(response_json.first['contacts'].length).to eq(2)
    end
  end
end
