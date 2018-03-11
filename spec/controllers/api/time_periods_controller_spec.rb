require 'rails_helper'

RSpec.describe Api::TimePeriodsController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:user) { create :user }
  let(:time_period_params) { attributes_for(:time_period) }

  before do
    sign_in user
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

  describe 'POST #create' do
    it 'creates a new time_period and returns success' do
      expect do
        post :create, time_period: time_period_params, format: :json
        expect(response).to be_success
      end.to change(TimePeriod, :count).by(1)
    end

    it 'returns errors if the time_period is invalid' do
      expect do
        post :create, time_period: { name: '' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
        expect(response_json['errors']['start_date']).to eq(["can't be blank"])
        expect(response_json['errors']['end_date']).to eq(["can't be blank"])
      end.to_not change(TimePeriod, :count)
    end
  end

  describe 'DELETE #destroy' do
    let!(:time_period) { create :time_period }

    it 'deletes the time period' do
      delete :destroy, id: time_period.id, format: :json
      expect(response).to be_success
      expect(time_period.reload.deleted_at).to_not be_nil
    end
  end


end
