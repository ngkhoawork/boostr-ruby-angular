require 'rails_helper'

RSpec.describe Api::DealsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:advertiser) { create :client, company: company }
  let(:deal_params) { attributes_for(:deal, advertiser_id: advertiser.id) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'returns a list of deals' do
      create_list :deal, 3, company: company, advertiser: advertiser

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe "POST #create" do
    it 'creates a new client and returns success' do
      expect{
        post :create, deal: deal_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['budget']).to eq(1)
        expect(response_json['advertiser_id']).to eq(advertiser.id)
      }.to change(Deal, :count).by(1)
    end

    it 'returns errors if the deal is invalid' do
      expect{
        post :create, deal: attributes_for(:deal), format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['advertiser_id']).to eq(["can't be blank"])
      }.to_not change(Client, :count)
    end

  end
end
