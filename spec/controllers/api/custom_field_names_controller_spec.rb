require 'rails_helper'

describe Api::CustomFieldNamesController do
  before { sign_in user }

  let!(:custom_field_name) do
    create(
      :custom_field_name,
      :with_option,
      subject_type: 'Activity',
      company: company
    )
  end
  let(:custom_field_option) { custom_field_name.custom_field_options[0] }

  describe '#index' do
    subject { get :index, params }

    let(:params) { { subject_type: 'activities' } }

    it 'returns a list of custom field names' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:id]).to eq custom_field_name.id
    end
  end

  describe '#show' do
    subject { get :show, params }

    let(:params) { { subject_type: 'activities', id: custom_field_name.id } }

    it 'returns a custom field name' do
      subject

      expect(response).to be_success
      expect(response_body[:id]).to eq custom_field_name.id
    end
  end

  describe '#create' do
    subject { post :create, params }

    let(:attributes) do
      attributes_for(:custom_field_name).merge(
        position: custom_field_name.position.next,
        custom_field_options_attributes: [
          { value: 'Test Option Value' }
        ]
      )
    end
    let(:params) do
      {
        subject_type: 'activities',
        custom_field_name: attributes
      }
    end

    it 'creates a custom field name' do
      expect{subject}.to change{CustomFieldName.count}.by(1).and \
                         change{CustomFieldOption.count}.by(1)
      expect(response).to have_http_status(201)
      expect(response_body[:id]).to eq CustomFieldName.last.id
    end
  end

  describe '#update' do
    subject { put :update, params }

    let(:attributes) do
      {
        field_label: 'New Field Label',
        custom_field_options_attributes: [
          {
            id: custom_field_option.id,
            value: 'New Test Option Value'
          }
        ]
      }
    end
    let(:params) do
      {
        subject_type: 'activities',
        id: custom_field_name.id,
        custom_field_name: attributes
      }
    end

    it 'updates a custom field name' do
      expect{subject}.to change{custom_field_name.reload.field_label}.to(params[:custom_field_name][:field_label]).and \
                         change{custom_field_option.reload.value}
      expect(response).to have_http_status(200)
      expect(response_body[:id]).to eq CustomFieldName.last.id
    end
  end

  describe '#destroy' do
    subject { delete :destroy, params }

    let(:params) do
      {
        subject_type: 'activities',
        id: custom_field_name.id
      }
    end

    it 'destroys a custom field name' do
      expect{subject}.to change{CustomFieldName.count}.by(-1)
      expect(response).to have_http_status(204)
    end
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def first_item
    @_first_item ||= response_body.first
  end

  def company
    @_company ||= create(:company)
  end

  def user
    @_user ||= create(:user, company: company)
  end
end
