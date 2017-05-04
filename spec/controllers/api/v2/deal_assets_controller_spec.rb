require 'rails_helper'

RSpec.describe Api::V2::DealAssetsController, type: :controller do
  let!(:company) { create :company }
  let!(:user) { create :user }
  let!(:deal) { create :deal_with_assets, assets_count: 5 }
  let(:asset_params) { attributes_for :asset }

  before do
    valid_token_auth user
    allow_message_expectations_on_nil
    allow(S3_BUCKET).to receive(:object)
  end

  describe 'GET #index' do
    it 'returns deal assets' do
      get :index, deal_id: deal.id

      expect(response).to be_success
      expect(json_response.length).to eq(5)
      expect(json_response).to eq(JSON.parse(deal.assets.to_json))
    end
  end

  describe 'POST #create' do
    it 'creates deal asset' do
      expect {
        post :create, deal_id: deal.id, asset: asset_params

        expect(response).to be_success
        expect(json_response).to eq(JSON.parse(deal.assets.last.to_json))
      }.to change(Asset, :count).by(1)
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal_asset) { create :asset, attachable: deal }

    it 'deletes the deal member' do
      expect {
        delete :destroy, id: deal_asset.id, deal_id: deal.id

        expect(response).to be_success
      }.to change(Asset, :count).by(-1)
    end
  end
end
