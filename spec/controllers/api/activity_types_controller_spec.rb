require 'rails_helper'

describe Api::ActivityTypesController do
  before { sign_in user }

  describe 'GET #index' do
    before do
      create :activity_type, position: 13, company: company
    end

    it 'return all activity types related to specific company' do
      get :index, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(13)
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
      expect{
        delete :destroy, id: activity_type.id, format: :json
      }.to change(ActivityType, :count).by(-1)
    end
  end

  describe 'PUT #update_positions' do
    it '' do
      activity_types = company.activity_types.sample(2)
      activity_types_ids = activity_types.map(&:id)
      position_params =  Hash[activity_types_ids.map { |i| [i, i+1] }]

      put :update_positions, activity_types_position: position_params, format: :json

      activity_types.map(&:reload)

      expect(activity_types.first.position).to eq(position_params[activity_types.first.id])
      expect(activity_types.last.position).to eq(position_params[activity_types.last.id])
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
    @_activity_type ||= company.activity_types.last
  end

  def valid_activity_type_params
    {
      name: 'Test',
      position: 13
    }
  end

  def invalid_activity_type_params
    {
      name: '',
      position: 13
    }
  end
end
