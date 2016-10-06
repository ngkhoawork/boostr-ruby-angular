require 'rails_helper'

RSpec.describe Api::DealProductBudgetsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:deal) { create :deal, company: company, creator: user }
  let(:product) { create :product, company: company }
  let(:deal_product_budget) { create :deal_product_budget, deal: deal, product: product }

  before do
    sign_in user
  end

  describe 'POST #create' do
    render_views

    it 'creates deal_product_budgets and returns the newly updated deal json' do
      expect do
        post :create, deal_id: deal.id, product_id: product.id, total_budget: '1000', format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['products'][0]['deal_product_budgets'].length).to eq(2)
        expect(response_json['budget']).to eq(100_000)
      end.to change(DealProductBudget, :count).by(2)
    end
  end

  describe 'PUT #update' do
    render_views

    it 'updates the budget amount of the deal_product_budget and the deal budget as well' do
      put :update, id: deal_product_budget.id, deal_id: deal.id, deal_product_budget: { budget: '62000' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['products'][0]['deal_product_budgets'][0]['budget']).to eq(62_000)
      expect(response_json['budget']).to eq(6_200_000)
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal_product_budget) { create :deal_product_budget, deal: deal, product: product }
    it 'deletes the deal product' do
      expect do
        delete :destroy, id: product.id, deal_id: deal.id, format: :json
        expect(response).to be_success
      end.to change(DealProductBudget, :count).by(-1)
    end
  end
end
