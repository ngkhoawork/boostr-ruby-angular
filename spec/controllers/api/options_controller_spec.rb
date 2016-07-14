require 'rails_helper'

RSpec.describe Api::OptionsController, type: :controller do

  let(:company) { Company.first }
  let(:user) { create :user }
  let(:option_params) { attributes_for :option }
  let(:field) { client_type_field(company) }
  let(:option) { create :option, field: field }

  before do
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new option and returns success' do
      expect do
        post :create, option: option_params, field_id: field.id, format: :json
        expect(response).to be_success
      end.to change(Option, :count).by(1)
    end

    it 'returns errors if the option is invalid' do
      expect do
        post :create, option: { name: '' }, field_id: field.id, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Option, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates the option and returns success' do
      put :update, id: option.id, field_id: field.id, option: { name: 'Option 2' }, format: :json
      expect(response).to be_success
    end
  end

  describe "DELETE #destroy" do
    it 'marks the client as deleted' do
      delete :destroy, id: option.id, field_id: field.id, format: :json
      expect(response).to be_success
      expect(option.reload.deleted_at).to_not be_nil
    end
  end
end
