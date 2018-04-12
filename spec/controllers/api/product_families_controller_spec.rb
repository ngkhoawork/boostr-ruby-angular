require 'rails_helper'

RSpec.describe Api::ProductFamiliesController, type: :controller do
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of product families' do
      create_list :product_family, 3, company: company
      create_list :product_family, 2, company: company, active: false


      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(5)
    end
    it 'returns a list of active product families' do
      create_list :product_family, 3, company: company
      create_list :product_family, 2, company: company, active: false


      get :index, active: true, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe 'POST #create' do
    it 'creates a new product family and returns success' do
      expect do
        post :create, product_family: product_family_params, format: :json
        expect(response).to be_success
      end.to change(ProductFamily, :count).by(1)
    end

    it 'returns errors if the product family is invalid' do
      expect do
        post :create, product_family: { blah: 'blah' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Product, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates a product family successfully' do
      put :update, id: product_family.id, product_family: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the product family' do
      product_family
      expect do
        delete :destroy, id: product_family.id, format: :json
        expect(response).to be_success
      end.to change(ProductFamily, :count).by(-1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def product_family_params
    @_product_family_params ||= attributes_for :product_family
  end
end
