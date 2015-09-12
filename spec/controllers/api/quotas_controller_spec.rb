require 'rails_helper'

RSpec.describe Api::QuotasController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:time_period) { create :time_period, company: company }
    let!(:quotas) { create_list :quota, 2, company: company }

    it 'returns a list of quotas' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end

    it 'returns a list of quotas for a specific time period' do
      get :index, time_period_id: time_period.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
    end
  end
end