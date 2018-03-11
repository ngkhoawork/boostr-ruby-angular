require 'rails_helper'

RSpec.describe Api::QuotasController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:user) { create :user }
  let(:time_period) { create :time_period }
  let(:other_time_period) {
    create :time_period, start_date: time_period.end_date + 1.month, end_date: time_period.end_date + 2.months
  }

  before do
    sign_in user
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
    let(:quota) { create :quota, value: 100, time_period: time_period }

    it 'updates the quotas value' do
      put :update, id: quota.id, quota: { value: 200 }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['value']).to eq(200)
    end
  end
end
