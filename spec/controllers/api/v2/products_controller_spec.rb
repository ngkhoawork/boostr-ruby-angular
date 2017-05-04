require 'rails_helper'

RSpec.describe Api::V2::ProductsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:product_params) { attributes_for :product }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns a list of products' do
      create_list :product, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end
end
