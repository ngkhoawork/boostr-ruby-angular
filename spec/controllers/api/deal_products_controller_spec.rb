require 'rails_helper'

RSpec.describe Api::DealProductsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:deal) { create :deal, company: company, creator: user }
  let(:product) { create :product, company: company }

  before do
    sign_in user
  end

  describe 'POST #create' do
    render_views

    it 'creates deal_products and returns the newly updated deal json' do
      expect{
        post :create, deal_id: deal.id, product_id: product.id, total_budget: "1000", format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['products'][0]['deal_products'].length).to eq(1)
      }.to change(DealProduct, :count).by(1)
    end
  end

end