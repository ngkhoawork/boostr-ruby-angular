require 'rails_helper'

RSpec.describe Api::DealAssetsController, type: :controller do
  let!(:company) { create :company }
  let!(:user) { create :user }
  let!(:deal) { create :deal_with_assets, assets_count: 5 }
  let(:asset_params) { attributes_for :asset }

  before do
    sign_in user
    allow_message_expectations_on_nil
    allow(S3_BUCKET).to receive(:object)
  end

  describe 'GET #index' do
    it 'returns deal assets' do
      get :index, deal_id: deal.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(5)
      expect(response_json).to eq(JSON.parse(deal.assets.to_json))
    end
  end

  describe 'POST #create' do
    it 'creates deal asset' do
      expect {
        post :create, deal_id: deal.id, asset: asset_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json).to eq(JSON.parse(deal.assets.last.to_json))
      }.to change(Asset, :count).by(1)
    end
  end
end
