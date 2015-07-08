require 'rails_helper'

RSpec.describe ClientsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:address_params) { attributes_for :address }
  let(:client_params) { attributes_for(:client, address_attributes: address_params) }

  before do
    sign_in user
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
end
