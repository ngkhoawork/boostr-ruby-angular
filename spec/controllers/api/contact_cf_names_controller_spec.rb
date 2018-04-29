require 'rails_helper'

RSpec.describe Api::ContactCfNamesController, type: :controller do
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'responds with success' do
      get :index

      expect(response).to be_success
    end

    it 'lists company contact custom field names' do
      contact_cf_names

      get :index

      expect(json_response.length).to be contact_cf_names.length
    end

    it 'lists related contact_cf_options' do
      contact_cf_names

      get :index

      expect(json_response.first).to include("contact_cf_options")
    end
  end

  describe 'GET #show' do
    it 'responds with success' do
      get :show, id: contact_cf_name.id

      expect(response).to be_success
    end

    it 'returns contact custom field name' do
      get :show, id: contact_cf_name.id

      expect(json_response["field_type"]).to eq contact_cf_name.field_type
    end

    it 'lists related contact_cf_options' do
      get :show, id: contact_cf_name.id

      expect(json_response["contact_cf_options"].first["value"])
      .to eql contact_cf_name.contact_cf_options.first.value
    end
  end

  describe 'PUT #update' do
    it 'updates contact cf name' do
      contact_cf_name(position: 1)
      option = contact_cf_name.contact_cf_options.first

      put :update, id: contact_cf_name.id,
      contact_cf_name: {
        position: 5,
        contact_cf_options_attributes: [{id: option.id.to_i, value: 'Updaterino'}]
      }

      expect(contact_cf_name.reload.position).to be 5
      expect(option.reload.value).to eql 'Updaterino'
    end

    it 'update dropdown options for contact cf option' do
      option = contact_cf_name.contact_cf_options

      put :update, id: contact_cf_name.id,
          contact_cf_name: {
              position: 5,
              contact_cf_options_attributes: {}
          }

      expect(option.reload).to be_empty
    end
  end

  describe 'POST #create' do
    it 'creates a new contact cf name' do
      cf_name_params(position: 1, field_type: 'dropdown')

      expect {
        post :create, contact_cf_name: cf_name_params
      }.to change(ContactCfName, :count).by 1
    end

    it 'sets contact_cf_name field index' do
      cf_name_params(field_label: 'Global Offence', field_type: 'dropdown')

      post :create, contact_cf_name: cf_name_params

      expect(json_response["field_index"]).to be 1
    end

    it 'disallows creation of new fields over limit' do
      create_list :contact_cf_name, 10, field_type: 'note', company: company
      cf_name_params(field_type: 'note')

      expect{
        post :create, contact_cf_name: cf_name_params
        expect(response.status).to eq(422)
        expect(json_response['errors']).to eq("field_type" => ["Note reached it's limit of 10"])
      }.to_not change(ContactCfName, :count)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the record' do
      contact_cf_name

      expect {
        delete :destroy, id: contact_cf_name.id
        expect(response).to be_success
      }.to change(ContactCfName, :count).by(-1)
    end
  end

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def contact_cf_names(opts={})
    opts.merge!(company: company)
    @_contact_cf_names ||= create_list :contact_cf_name, 4, opts
  end

  def contact_cf_name(opts={})
    opts.merge!(company: company)
    @_contact_cf_name ||= create :contact_cf_name, opts    
  end

  def cf_name_params(opts={})
    @_cf_name_params ||= attributes_for :contact_cf_name, opts
  end
end
