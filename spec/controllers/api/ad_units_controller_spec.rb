require 'rails_helper'

describe Api::AdUnitsController do
  before { sign_in user }

  describe 'GET #index' do
    it 'assigns all api_ad_units as ad_units' do
      2.times { create :ad_unit, product: product }

      get :index, product_id: product, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'POST #create' do
    it 'creates a new AdUnit with valid params' do
      expect {
        post :create, product_id: product, ad_unit: { name: 'Some name' }, format: :json
      }.to change(AdUnit, :count).by(1)
    end

    it 'does not create a new AdUnit with invalid params' do
      expect {
        post :create, product_id: product, ad_unit: { name: '' }, format: :json
      }.to_not change(AdUnit, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates AdUnit with valid params' do
      put :update, product_id: product, id: ad_unit, ad_unit: { name: 'Some name' }, format: :json

      expect(ad_unit.reload.name).to eql('Some name')
    end

    it 'does not update AdUnit with invalid params' do
      put :update, product_id: product, id: ad_unit, ad_unit: { name: '' }, format: :json

      expect(ad_unit.reload.name).to_not eql('Some name')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys AdUnit successfully' do
      ad_unit = create :ad_unit, product: product

      expect {
        delete :destroy, product_id: product, id: ad_unit, format: :json
      }.to change(AdUnit, :count).by(-1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def ad_unit
    @_ad_unit ||= create :ad_unit, product: product
  end

  def product
    @_product ||= create :product, company: company
  end
end
