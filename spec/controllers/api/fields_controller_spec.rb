require 'rails_helper'

RSpec.describe Api::FieldsController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
    create_list :field, 2, subject_type: 'Deal'
    create_list :field, 2, subject_type: 'Client'
  end

  describe "GET #index" do
    it 'returns a list of Deal fields in json' do
      get :index, { format: :json, subject: 'Deal' }
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(2)
    end

    it 'returns a list of Client fields in json' do
      get :index, { format: :json, subject: 'Client' }
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end
end
