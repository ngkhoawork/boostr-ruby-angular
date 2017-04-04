require 'rails_helper'

RSpec.describe Api::V1::StagesController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company }
  let(:stage_params) { attributes_for(:stage, company: company) }

  before do
    valid_token_auth user
  end

  describe "GET #index" do
    it 'returns a list of stages' do
      create_list :stage, 3, company: company

      get :index

      expect(response).to be_success
      expect(json_response.length).to eq(3)
    end
  end

  describe 'POST #create' do
    it 'creates a new stage and returns success' do
      expect do
        post :create, stage: stage_params

        expect(response).to be_success
      end.to change(Stage, :count).by(1)
    end

    it 'returns errors if the stage is invalid' do
      expect do
        post :create, stage: { name: '' }

        expect(response.status).to eq(422)
        expect(json_response['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Stage, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates the stage and returns success' do
      put :update, id: stage.id, stage: { name: 'Stage 2' }

      expect(response).to be_success
    end
  end
end
