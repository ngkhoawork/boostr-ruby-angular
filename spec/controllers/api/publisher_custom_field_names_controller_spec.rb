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

    context 'filter by field_type field' do
      before { create :publisher_custom_field_name, company: company, field_type: 'integer' }

      it 'expect to find records by specific field type' do
        get :index, field_type: 'integer'

        expect(json_response.length).to be 1
      end

      it 'expect not to find records by specific field type' do
        get :index, field_type: 'text'

        expect(json_response.length).to be 0
      end
    end

    context 'filter by is_required field' do
      before { create :publisher_custom_field_name, company: company, is_required: true }

      it 'expect to find records by is_required' do
        get :index, is_required: 'true'

        expect(json_response.length).to be 1
      end

      it 'expect not to find records by is_required' do
        get :index, is_required: 'false'

        expect(json_response.length).to be 0
      end
    end

    context 'filter by show_on_modal field' do
      before { create :publisher_custom_field_name, company: company, show_on_modal: true }

      it 'expect to find records by show_on_modal' do
        get :index, show_on_modal: 'true'

        expect(json_response.length).to be 1
      end

      it 'expect not to find records by show_on_modal' do
        get :index, show_on_modal: 'false'

        expect(json_response.length).to be 0
      end
    end

    context 'filter by disabled field' do
      before { create :publisher_custom_field_name, company: company, disabled: true }

      it 'expect to find records by disabled' do
        get :index, disabled: 'true'

        expect(json_response.length).to be 1
      end

      it 'expect not to find records by disabled' do
        get :index, disabled: 'false'

        expect(json_response.length).to be 0
      end
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
