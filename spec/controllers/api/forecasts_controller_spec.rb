require 'rails_helper'

RSpec.describe Api::ForecastsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:parent_team) { create :parent_team, company: company, leader: user }
  let(:time_period) { create :time_period, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'as a leader' do
      it 'returns a list of root teams' do
        parent_team
        create_list :parent_team, 2, company: company

        get :index, { format: :json, time_period_id: time_period.id }
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json[0]['teams'].length).to eq(3)
      end
    end

    context 'as a non-leader' do
      it 'returns only the user\'s forecast' do
        create_list :parent_team, 2, company: company

        get :index, { format: :json, time_period_id: time_period.id }
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json[0]['name']).to eq(user.name)
      end
    end
  end

  describe 'GET #show' do
    let(:child_team) { create :child_team, parent: parent_team, company: company }

    it 'returns json for a team' do
      get :show, { id: child_team.id, format: :json, time_period_id: time_period.id }
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq(child_team.name)
    end
  end
end
