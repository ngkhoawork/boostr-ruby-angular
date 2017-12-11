require 'rails_helper'

describe Api::ForecastsController do
  before do
    sign_in user
  end

  describe 'New GET #index' do
    context 'without filters' do
      it 'returns a list of root teams' do
        parent_team
        create_list :parent_team, 2

        get :index, format: :json, new_version: 'true', time_period_id: time_period.id,
              team_id: 'all', product_id: 'all', user_id: 'all'

        response_json = JSON.parse(response.body)
        expect(response).to be_success
        expect(response_json[0]['teams'].length).to eq(3)
      end
    end

    context 'with team filter' do
      it 'returns a team data' do
        parent_team
        create_list :user, 2, team: parent_team

        get :index, format: :json, new_version: 'true', time_period_id: time_period.id,
              team_id: parent_team.id, product_id: 'all', user_id: 'all'

        response_json = JSON.parse(response.body)
        expect(response).to be_success
        expect(response_json[0]['name']).to eq(parent_team.name)
        expect(response_json[0]['type']).to eq('team')
        expect(response_json[0]['leader']['id']).to eq(user.id)
        expect(response_json[0]['members'].count).to eq 3
      end
    end

    context 'with user filter' do
      it 'returns a member data' do
        parent_team
        create_list :user, 2, team: parent_team

        get :index, format: :json, new_version: 'true', time_period_id: time_period.id,
              team_id: parent_team.id, product_id: 'all', user_id: user.id

        response_json = JSON.parse(response.body)
        expect(response).to be_success
        expect(response_json[0]['name']).to eq(user.name)
        expect(response_json[0]['type']).to eq('member')
      end
    end

    context 'with all filter' do
      it 'returns a user data' do
        parent_team
        create_list :user, 2, team: parent_team

        get :index, format: :json, new_version: 'true', time_period_id: time_period.id, 
              team_id: parent_team.id, product_id: product.id, user_id: user.id

        response_json = JSON.parse(response.body)
        expect(response).to be_success
        expect(response_json[0]['name']).to eq(user.name)
        expect(response_json[0]['type']).to eq('member')
      end
    end
  end

  describe 'Old GET #index' do
    context 'as a leader' do
      it 'returns a list of root teams' do
        parent_team
        create_list :parent_team, 2, company: company

        get :index, format: :json, time_period_id: time_period.id

        response_json = JSON.parse(response.body)
        expect(response).to be_success
        expect(response_json[0]['teams'].length).to eq(3)
      end
    end

    context 'as a non-leader' do
      it 'returns only the user\'s forecast' do
        create_list :parent_team, 2, company: company

        get :index, format: :json, time_period_id: time_period.id

        response_json = response_json(response)
        expect(response).to be_success
        expect(response_json[0]['teams'].count).to eq 2
        expect(response_json[0]['team_members'].count).to eq 1
      end
    end
  end

  describe 'GET #show' do
    it 'returns json for a team' do
      get :show, id: child_team.id, format: :json, time_period_id: time_period.id

      response_json = JSON.parse(response.body)
      expect(response).to be_success
      expect(response_json['name']).to eq(child_team.name)
    end
  end

  def company
    @_company ||= Company.first
  end

  def user
    @_user ||= create :user
  end

  def product
    @_product ||= create :product
  end

  def child_team
    @_child_team ||= create :child_team, parent: parent_team, company: company
  end

  def parent_team
    @_parent_team ||= create :parent_team, leader: user
  end

  def time_period
    @_time_period ||= create :time_period, period_type: 'quarter'
  end
end

