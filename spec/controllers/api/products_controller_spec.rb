require 'rails_helper'

RSpec.describe Api::ProductsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:product_params) { attributes_for :product }

  before do
    sign_in user
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

  describe 'POST #create' do
    it 'creates a new product and returns success' do
      expect do
        post :create, product: product_params, format: :json
        expect(response).to be_success
      end.to change(Product, :count).by(1)
    end

    it 'returns errors if the product is invalid' do
      expect do
        post :create, product: { blah: 'blah' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Product, :count)
    end
  end

  describe 'PUT #update' do
    let(:product) { create :product, company: company }

    it 'updates a product successfully' do
      put :update, id: product.id, product: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end
end
