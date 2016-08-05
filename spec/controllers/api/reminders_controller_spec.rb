require 'rails_helper'

RSpec.describe Api::RemindersController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:reminder_params) { attributes_for(:reminder, remindable_id: 130) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new reminder and returns success' do
      expect do
        post :create, reminder: reminder_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['user_id']).to eq(user.id)
        expect(response_json['name']).to eq(reminder_params[:name])
        expect(response_json['comment']).to eq(reminder_params[:comment])
        expect(response_json['remind_on']).to eq(reminder_params[:remind_on].as_json)
        expect(response_json['remindable_id']).to eq(reminder_params[:remindable_id])
      end.to change(Reminder, :count).by(1)
    end

    it 'returns errors if the reminder is invalid' do
      expect do
        post :create, reminder: {malformed: true}, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
        expect(response_json['errors']['remind_on']).to eq(["can't be blank"])
        expect(response_json['errors']['remindable_id']).to eq(["can't be blank"])
      end.not_to change(Reminder, :count)
    end
  end
end
