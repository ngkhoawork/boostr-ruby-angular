require 'rails_helper'

RSpec.describe Api::QuotasController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:time_period) { create :time_period, company: company }
  let(:other_time_period) { create :time_period, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:quotas) { create_list :quota, 2, company: company, time_period: time_period }

    it 'returns a list of quotas' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end

    it 'returns a list of quotas for a specific time period' do
      get :index, time_period_id: other_time_period.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
    end
  end

  describe 'POST #create' do
    let(:quota_params) { attributes_for :quota, value: 100, user_id: user.id, time_period_id: time_period.id }

    it 'creates a quota' do
      post :create, quota: quota_params, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['value']).to eq(100)
    end
  end

  describe 'PUT #update' do
    let(:quota) { create :quota, value: 100, company: company, time_period: time_period }

    it 'updates the quotas value' do
      put :update, id: quota.id, quota: { value: 200 }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['value']).to eq(200)
    end
  end
end