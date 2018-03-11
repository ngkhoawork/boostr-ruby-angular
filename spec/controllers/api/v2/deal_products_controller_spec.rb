require 'rails_helper'

describe Api::V2::DealProductsController do
  let!(:company) { create :company }
  let(:user) { create :user }
  let(:deal) { create :deal, creator: user }
  let(:product) { create :product, company: user.company }
  let(:deal_product) { create :deal_product, deal: deal, product: product }

  before do
    valid_token_auth user
    User.current = user
  end

  describe 'PUT #update' do
    render_views

    it 'updates the budget amount of the deal_product_budget and the deal budget as well' do
      put :update, id: deal_product.id, deal_id: deal.id, deal_product: { budget_loc: '62000' }, format: :json

      expect(response).to be_success
      expect(json_response['deal_products'][0]['budget_loc']).to eq(62_000)
      expect(json_response['budget_loc'].to_i).to eq(62_000)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the deal product' do
      deal_product = create :deal_product, deal: deal, product: product

      expect{
        delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json
        expect(response).to be_success
      }.to change(DealProduct, :count).by(-1)
    end

    it 'updates deal\'s total budget' do
      deal.update(budget: deal_product.budget)

      expect(deal.budget).to eq(deal_product.budget)

      delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json

      expect(deal.reload.budget).to eq(0)
    end
  end
end
