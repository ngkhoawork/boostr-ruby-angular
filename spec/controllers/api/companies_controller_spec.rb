require 'rails_helper'

RSpec.describe Api::CompaniesController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns json for a deal, products and deal_products' do
      get :show, format: :json
      expect(response).to be_success
    end
  end

  describe 'PUT #update' do
    it 'updates the deal and returns success' do
      put :update, company: { snapshot_day: 'Tuesday' }, format: :json
      expect(response).to be_success
    end
  end
end
