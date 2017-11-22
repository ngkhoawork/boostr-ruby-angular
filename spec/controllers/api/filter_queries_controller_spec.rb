require 'rails_helper'

describe Api::FilterQueriesController do
  before { sign_in user }
  
  describe 'GET #index' do
    it 'return filter queries by user without global records' do
      create_list :filter_query, 2, user: user, company: company, query_type: 'pipeline_summary_report'

      get :index, format: :json, query_type: 'pipeline_summary_report'

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end

    it 'return filter queries by user with global records' do
      create_list :filter_query, 2, user: user, company: company, query_type: 'pipeline_summary_report'
      create_list :filter_query, 3, user: user, company: company, query_type: 'pipeline_summary_report', global: true

      get :index, format: :json, query_type: 'pipeline_summary_report'

      expect(response).to be_success
      expect(response_json(response).length).to eq(5)
    end

    it 'return filter queries by user only with specific query type' do
      create_list :filter_query, 2, user: user, company: company, query_type: 'pipeline_summary_report'
      create_list :filter_query, 2, user: user, company: company, query_type: 'pipeline_split_report'

      get :index, format: :json, query_type: 'pipeline_split_report'

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'POST #create' do
    it 'creates new filter query with valid params successfully' do
      expect{
        post :create, filter_query: valid_filter_query_params, format: :json
      }.to change(FilterQuery, :count).by(1)
    end

    it 'failed when params are invalid' do
      expect{
        post :create, filter_query: invalid_filter_query_params, format: :json
      }.to_not change(FilterQuery, :count)
    end

    it 'change previous default filter query if new one became default' do
      filter_query.update(default: true)

      post :create, filter_query: valid_filter_query_params.merge(default: true), format: :json

      expect(filter_query.reload.default).to be_falsey
    end

    it 'does not create new record if name was already taken in scope of company and query type' do
      filter_query = create(
        :filter_query,
        user: user,
        company: company,
        name: 'One Report',
        query_type: 'pipeline_summary_report'
      )

      expect{
        post :create, filter_query: valid_filter_query_params, format: :json
      }.to_not change(FilterQuery, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates filter query with valid params successfully' do
      put :update, id: filter_query.id, filter_query: valid_filter_query_params, format: :json

      filter_query.reload

      expect(filter_query.name).to eq valid_filter_query_params[:name]
      expect(filter_query.query_type).to eq valid_filter_query_params[:query_type]
    end

    it 'does not update filter query with invalid params' do
      put :update, id: filter_query.id, filter_query: invalid_filter_query_params, format: :json

      filter_query.reload

      expect(filter_query.name).not_to eq invalid_filter_query_params[:name]
      expect(filter_query.query_type).not_to eq invalid_filter_query_params[:query_type]
    end

    it 'change previous default filter query if update default value' do
      filter_query = create :filter_query, user: user, company: company, default: true

      post :create, filter_query: valid_filter_query_params.merge(default: true), format: :json

      expect(filter_query.reload.default).to be_falsey
    end
  end

  describe 'DELETE #destroy' do
    it 'delete filter query successfully' do
      filter_query = create :filter_query, user: user, company: company

      expect{
        delete :destroy, id: filter_query.id, format: :json
      }.to change(FilterQuery, :count).by(-1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def filter_query
    @_filter_query ||= create :filter_query, user: user, company: company
  end

  def valid_filter_query_params
    {
      name: 'One Report',
      query_type: 'pipeline_summary_report',
      filter_params: { user_id: 1, team_id: 2 }
    }
  end

  def invalid_filter_query_params
    {
      name: '',
      query_type: '',
      filter_params: {}
    }
  end
end
