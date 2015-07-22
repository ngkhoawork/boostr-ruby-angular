require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client) { create :client, company: company }
  let(:address_params) { attributes_for :address }
  let(:contact_params) { attributes_for(:contact, address_attributes: address_params) }

  before do
    sign_in user
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
end