require 'rails_helper'

RSpec.describe Api::TeamsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:team_params) { attributes_for(:parent_team) }
  let(:team) { create :parent_team, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of teams' do
      create_list :parent_team, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe 'POST #create' do
    it 'creates a new team and returns success' do
      expect do
        post :create, team: team_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['name']).to eq(team_params[:name])
      end.to change(Team, :count).by(1)
    end

    it 'returns errors if the team is invalid' do
      expect do
        post :create, team: { blah: 'blah' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Team, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates a team successfully' do
      put :update, id: team.id, team: { name: 'Change Team Name', leader_id: user.id, member_ids: [user.id] }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('Change Team Name')
      expect(response_json['leader_id']).to eq(user.id)
    end
  end

  describe 'GET #show' do
    it 'returns json for a team' do
      get :show, id: team.id, format: :json
      expect(response).to be_success
    end
  end
end
