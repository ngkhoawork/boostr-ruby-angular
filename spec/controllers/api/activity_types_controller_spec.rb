require 'rails_helper'

describe Api::ActivityTypesController do
  before { sign_in user }

  describe 'GET #index' do
    it 'return all activity types related to specific company' do
      create_list :activity_type, 5, company: company

      get :index, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(5)
    end

    it 'return only active activity types related to specific company' do
      create :activity_type, position: 1, company: company, active: false
      create :activity_type, position: 2, company: company, active: true

      get :index, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(1)
    end
  end

  describe 'POST #create' do
    it 'creates new activity type with valid params successfully' do
      expect{
        post :create, activity_type: valid_activity_type_params, format: :json
      }.to change(ActivityType, :count).by(1)
    end

    it 'failed to create new activity type when params are invalid' do
      expect{
        post :create, activity_type: invalid_activity_type_params, format: :json
      }.to_not change(ActivityType, :count)
    end
  end

  describe 'PUT #update' do
    it 'update activity type with valid params successfully' do
      put :update, id: activity_type.id, activity_type: valid_activity_type_params, format: :json

      activity_type.reload

      expect(activity_type.name).to eq valid_activity_type_params[:name]
    end

    it 'failed to update activity type when params are invalid' do
      put :update, id: activity_type.id, activity_type: invalid_activity_type_params, format: :json

      activity_type.reload

      expect(activity_type.name).to_not eq invalid_activity_type_params[:name]
    end
  end

  describe 'DELETE #destroy' do
    it 'delete activity type successfully' do
      activity_type

      expect{
        delete :destroy, id: activity_type.id, format: :json
      }.to change(ActivityType, :count).by(-1)
    end
  end

  describe 'PUT #update_positions' do
    it 'update activity types positions successfully' do
      create :activity_type, position: 1, company: company, active: true
      create :activity_type, position: 2, company: company, active: true

      activity_types = company.activity_types
      type_ids = activity_types.ids
      position_params = {type_ids[0].to_s => type_ids[1], type_ids[1].to_s => type_ids[0]}

      put :update_positions, activity_types_position: position_params, format: :json

      activity_types.map(&:reload)

      expect(activity_types.first.position).to eq(position_params[activity_types.first.id.to_s])
      expect(activity_types.last.position).to eq(position_params[activity_types.last.id.to_s])
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company, user_type: ADMIN
  end

  def activity_type
    @_activity_type ||= create :activity_type, company: company
  end

  def valid_activity_type_params
    {
      name: 'Test',
      action: 'For test',
      position: 1
    }
  end

  def invalid_activity_type_params
    {
      name: ''
    }
  end
end
