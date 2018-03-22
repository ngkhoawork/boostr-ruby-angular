require 'rails_helper'

describe Api::DealProductsController do
  let!(:company) { create :company }
  let(:user) { create :user }
  let(:deal) { create :deal, creator: user }
  let(:product) { create :product, company: user.company }
  let(:deal_product) { create :deal_product, deal: deal, product: product }

  before do
    sign_in user
    User.current = user
  end

  describe 'POST #create' do
    it 'creates audit logs for deal when budget on deal product was created' do
      post :create,
           deal_id: deal.id,
           deal_product: {
             budget_loc: '2000',
             product_id: product.id,
             deal_product_budgets_attributes: [
               { budget_loc: 1000, percent_value: 50 },
               { budget_loc: 1000, percent_value: 50 }
             ],
           },
           format: :json

      audit_log = deal.audit_logs.last

      expect(audit_log.type_of_change).to eq 'Budget Change'
      expect(audit_log.old_value).to eq '0.0'
      expect(audit_log.new_value).to eq '2000.0'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.changed_amount).to eq 2000.0
    end
  end

  describe 'PUT #update' do
    render_views

    it 'updates the budget amount of the deal_product_budget and the deal budget as well' do
      put :update, id: deal_product.id, deal_id: deal.id, deal_product: { budget_loc: '62000' }, format: :json

      expect(response).to be_success
      expect(json_response['deal_products'][0]['budget_loc']).to eq(62_000)
      expect(json_response['budget_loc'].to_i).to eq(62_000)
    end

    it 'creates audit logs for deal when budget on deal product was updated' do
      deal_product = create :deal_product, deal: deal, product: product, budget: 10_000

      expect{
        put :update, id: deal_product.id, deal_id: deal.id, deal_product: { budget_loc: '20000' }, format: :json
      }.to change(AuditLog, :count).by(1)

      audit_log = deal.audit_logs.last

      expect(audit_log.type_of_change).to eq 'Budget Change'
      expect(audit_log.old_value).to eq '0.0'
      expect(audit_log.new_value).to eq '20000.0'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.changed_amount).to eq 20000.0
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal_product) { create :deal_product, deal: deal, product: product, budget: 20_000 }

    it 'deletes the deal product' do
      expect{
        delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json
        expect(response).to be_success
      }.to change(DealProduct, :count).by(-1)
    end

    it 'updates deal\'s total budget' do
      deal.budget = deal_product.budget
      deal.save
      expect(deal.budget).to eq(deal_product.budget)
      delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json
      deal.reload
      expect(deal.budget).to eq(0)      
    end

    it 'creates audit logs for deal when budget on deal product was deleted' do
      create :deal_product, deal: deal, product: product, budget: 10_000
      deal.update(budget: 30_000)

      delete :destroy, id: deal_product.id, deal_id: deal.id, format: :json

      audit_log = deal.audit_logs.last

      expect(audit_log.type_of_change).to eq 'Budget Change'
      expect(audit_log.old_value).to eq '30000.0'
      expect(audit_log.new_value).to eq '10000.0'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.changed_amount).to eq -20000.0
    end
  end
end
