require 'rails_helper'

RSpec.describe Api::DealProductsController, type: :controller do
  let!(:user) { create :user }
  let!(:deal) { create :deal, creator: user }
  let!(:product) { create :product, company: user.company }
  let!(:deal_product) { create :deal_product, deal: deal, product: product }

  before do
    sign_in user
  end

  describe 'PUT #update' do
    render_views

    it 'updates the budget amount of the deal_product_budget and the deal budget as well' do
      put :update, id: deal_product.id, deal_id: deal.id, deal_product: { budget: '62000' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['deal_products'][0]['budget']).to eq(62_000)
      expect(response_json['budget']).to eq(6_200_000)
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create :deal, creator: user }
    let!(:deal_product) { create :deal_product, deal: deal, product: product }

    it 'deletes the deal product' do
      expect do
        delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json
        expect(response).to be_success
      end.to change(DealProduct, :count).by(-1)
    end

    it 'updates deal\'s total budget' do
      deal.budget = deal_product.budget
      deal.save
      expect(deal.budget).to eq(deal_product.budget)
      delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json
      deal.reload
      expect(deal.budget).to eq(0)      
    end
  end
end
