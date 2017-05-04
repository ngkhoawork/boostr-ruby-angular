require 'rails_helper'

RSpec.describe Api::V2::DealCustomFieldNamesController, type: :controller do
  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'responds' do
      get :index

      expect(response).to be_success
    end

    it 'lists deal custom field names' do
      deal_custom_field_names(company: company, field_label: 'Testing Fields')

      get :index

      expect(json_response.first['field_label']).to eql 'Testing Fields'
    end
  end

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def deal_custom_field_names(opts={})
    @_deal_custom_field_names ||= create_list :deal_custom_field_name, 2, opts
  end
end
