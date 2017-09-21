require 'rails_helper'

RSpec.describe Api::V2::RemindersController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:reminder_params) { attributes_for(:reminder, remindable_id: 130, remindable_type: "Deal") }
  let!(:reminder) { create(:reminder, remindable_id: 130, remindable_type: "Deal", user_id: user.id) }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns json for all user\'s reminders' do
      get :index

      expect(response).to be_success
      expect(json_response.length).to eq 1
      expect(json_response.first['user_id']).to eq(user.id)
    end
  end

  describe 'GET #show' do
    it 'returns json for a reminder' do
      get :show, id: reminder.remindable_id

      expect(response).to be_success
    end
  end

  describe 'GET #remindable' do
    it 'returns json for a reminder' do
      get :remindable, remindable_id: reminder.remindable_id, remindable_type: reminder.remindable_type

      expect(response).to be_success
      expect(json_response.length).to eq(1)
    end
  end

  describe 'POST #create' do
    it 'creates a new reminder and returns success' do
      expect do
        post :create, reminder: reminder_params, format: :json

        expect(response).to be_success
        expect(json_response['user_id']).to eq(user.id)
        expect(json_response['name']).to eq(reminder_params[:name])
        expect(json_response['comment']).to eq(reminder_params[:comment])
        expect(json_response['remind_on']).to eq(reminder_params[:remind_on].as_json)
        expect(json_response['remindable_id']).to eq(reminder_params[:remindable_id])
      end.to change(Reminder, :count).by(1)
    end

    it 'returns errors if the reminder is invalid' do
      expect do
        post :create, reminder: {malformed: true}

        expect(response.status).to eq(422)
        expect(json_response['errors']['name']).to eq(['can\'t be blank'])
        expect(json_response['errors']['remind_on']).to eq(['can\'t be blank'])
        expect(json_response['errors']['completed']).to eq(['is not included in the list'])
      end.not_to change(Reminder, :count)
    end
  end

  describe 'PUT #update' do
    let(:new_time) { Time.zone.now + 10.hours }
    let(:invalid_reminder) { attributes_for(:reminder, remindable_id: nil, name: nil, remind_on: nil) }

    it 'returns success' do
      put :update, id: reminder.id, reminder: { remind_on: new_time }

      expect(response).to be_success
    end

    it 'updates the reminder' do
      put :update, id: reminder.id, reminder: { remind_on: new_time }, format: :json

      expect(json_response['remind_on']).to eq(new_time.as_json)
    end

    it 'returns an error if the reminder is invalid' do
      expect do
        put :update, id: reminder.id, reminder: invalid_reminder

        expect(response.status).to eq(422)
        expect(json_response['errors']['name']).to eq(["can't be blank"])
        expect(json_response['errors']['remind_on']).to eq(["can't be blank"])
      end.not_to change(Reminder, :count)
    end
  end

  describe 'DELETE #destroy' do
    let!(:reminder) { create(:reminder, remindable_id: 160, remindable_type: "Deal", user_id: user.id) }

    it 'marks the deal as deleted' do
      delete :destroy, id: reminder.id

      expect(response).to be_success
      expect(reminder.reload.deleted_at).not_to be_nil
    end
  end
end
