require 'rails_helper'

RSpec.describe Api::StagesController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe "GET #index" do
    it 'returns a list of stages' do
      create_list :stage, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end
end
