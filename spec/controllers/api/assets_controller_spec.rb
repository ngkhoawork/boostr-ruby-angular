require 'rails_helper'

describe Api::AssetsController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:user) { create :user }

  before do
    sign_in user
    allow_message_expectations_on_nil
    allow(S3_BUCKET).to receive(:object)
  end

  describe 'POST #create' do
    it 'creates a new asset and returns success' do
      expect {
        post :create, asset: asset_params, format: :json
        expect(response).to be_success
        expect(json_response['asset_file_name']).to eq asset_params[:asset_file_name]
      }.to change(Asset, :count).by(1)
    end

    it 'creates multiple assets at once' do
      expect {
        post :create, assets: assets_params, format: :json
        expect(response).to be_success
      }.to change(Asset, :count).by(10)
    end
  end

  def asset_params
    @_asset_params ||= attributes_for :asset
  end

  def assets_params
    @_assets_params ||= attributes_for_list :asset, 10
  end
end
