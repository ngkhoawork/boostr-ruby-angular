require 'rails_helper'

RSpec.describe Api::DealProductCfNamesController, type: :controller do
  before { sign_in user }

  describe 'POST #create' do
    it 'create Deal product custom field name' do
      params = { deal_product_cf_name: { field_type: 'text', position: 1 } }

      expect do
        post :create, params, format: :json
      end.to change { DealProductCfName.count }.by(1)
             .and change { DealCustomFieldName.count }.by(0)
    end

    it 'create Deal product custom field name and Deal custom field name when field type is sum' do
      params = { deal_product_cf_name: { field_type: 'sum', position: 1 } }

      expect do
        post :create, params, format: :json
      end.to change { DealProductCfName.count }.by(1)
             .and change { DealCustomFieldName.count }.by(1)

      deal_custom_field_name = DealCustomFieldName.last
      deal_product_cf_name   = DealProductCfName.last

      expect(deal_custom_field_name.field_index).to eq(deal_product_cf_name.field_index)
    end

    context 'position has already been taken' do
      before { create_deal_product_cf_name }

      it 'raise validation error' do
        params = { deal_product_cf_name: { field_type: 'text', position: 1 } }

        expect do
          post :create, params, format: :json
        end.to change { DealProductCfName.count }.by(0)
               .and change { DealCustomFieldName.count }.by(0)
      end

      it 'does not create Deal custom field name for sum field type' do
        params = { deal_product_cf_name: { field_type: 'sum', position: 1 } }

        expect do
          post :create, params, format: :json
        end.to change { DealProductCfName.count }.by(0)
               .and change { DealCustomFieldName.count }.by(0)
      end
    end
  end

  private

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def create_deal_product_cf_name
    create :deal_product_cf_name, company: company, position: 1
  end
end
