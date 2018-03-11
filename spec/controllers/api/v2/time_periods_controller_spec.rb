require 'rails_helper'

RSpec.describe Api::V2::TimePeriodsController, type: :controller do
  let!(:company) { create :company }
  let(:user) { create :user }
  let(:time_period_params) { attributes_for(:time_period) }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns a list of time periods' do
      create_list :time_period, 2

      get :index

      expect(response).to be_success
      expect(json_response.length).to eq(2)
    end
  end
end
