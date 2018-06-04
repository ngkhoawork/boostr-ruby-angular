require 'rails_helper'

RSpec.describe Api::AccountCfNamesController, type: :controller do
  before { sign_in user }

  describe 'POST #create' do
    it 'create Account custom field name' do
      params = { account_cf_name: { field_type: 'text', position: 1 } }

      expect do
        post :create, params, format: :json
      end.to change { AccountCfName.count }.by(1)
    end

    context 'position has already been taken' do
      before { create_account_custom_field_name }

      it 'raise validation error when position has already been taken' do
        params = { account_cf_name: { field_type: 'text', position: 1 } }

        expect do
          post :create, params, format: :json
        end.to_not change { AccountCfName.count }
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

  def create_account_custom_field_name
    create :account_cf_name, company: company, position: 1
  end
end
