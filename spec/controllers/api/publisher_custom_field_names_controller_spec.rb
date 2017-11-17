require 'rails_helper'

describe Api::PublisherCustomFieldNamesController do
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'expect publisher custom field names list for company' do
      create :publisher_custom_field_name, company: company

      get :index

      expect(json_response.length).to be 1
    end
  end

  describe 'POST #create' do
    it 'creates a new publisher custom field name' do
      expect {
        post :create, publisher_custom_field_name: valid_publisher_custom_field_name_params
      }.to change(PublisherCustomFieldName, :count).by 1
    end

    it 'failed to create a new publisher custom field name' do
      expect {
        post :create, publisher_custom_field_name: invalid_publisher_custom_field_name_params
      }.to_not change(PublisherCustomFieldName, :count)
    end
  
    it 'failed to create a new publisher custom field name when limit by type was exceeded' do
      create_list :publisher_custom_field_name, 2, field_type: 'note', company: company

      expect {
        post :create, publisher_custom_field_name: valid_publisher_custom_field_name_params
      }.to_not change(PublisherCustomFieldName, :count)
    end
  end

  describe 'POST #create' do
    it 'updates publisher custom field name' do
      expect(publisher_custom_field_name.field_label).not_to eq 'Updated label'

      put :update, 
          id: publisher_custom_field_name.id, 
          publisher_custom_field_name: valid_publisher_custom_field_name_params.merge(field_label: 'Updated label')
      
      expect(publisher_custom_field_name.reload.field_label).to eq 'Updated label'
    end

    it 'failed to update publisher custom field name' do
      expect(publisher_custom_field_name.field_label).not_to eq 'Updated label'

      put :update,
          id: publisher_custom_field_name.id,
          publisher_custom_field_name: invalid_publisher_custom_field_name_params

      expect(publisher_custom_field_name.reload.field_label).not_to eq 'Updated label'
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the record' do
      publisher_custom_field_name = create :publisher_custom_field_name, company: company

      expect {
        delete :destroy, id: publisher_custom_field_name.id
      }.to change(PublisherCustomFieldName, :count).by -1
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def publisher_custom_field_name
    @_publisher_custom_field_name ||= create :publisher_custom_field_name, company: company
  end

  def valid_publisher_custom_field_name_params
    attributes_for :publisher_custom_field_name
  end

  def invalid_publisher_custom_field_name_params
    {
      field_index: '',
      field_type: 'note',
      field_label: '',
      position: ''
    }
  end
end
