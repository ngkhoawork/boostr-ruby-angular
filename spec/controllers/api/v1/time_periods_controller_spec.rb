require 'rails_helper'

RSpec.describe Api::V1::TimePeriodsController, type: :controller do
  let(:company) { Company.first }
  let(:user) { create :user }
  let(:time_period_params) { attributes_for(:time_period) }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns a list of time periods' do
      create_list :time_period, 2

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(2)
    end
  end
end
