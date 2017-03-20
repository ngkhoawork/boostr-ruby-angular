require 'rails_helper'

describe Api::InitiativesController do
  before { sign_in user }

  describe 'GET #index' do
    before do
      2.times { create :initiative, company: company }
      create :initiative, company: create(:company)
    end

    it 'return all initiatives related to specific company' do
      get :index, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'POST #create' do
    it 'creates new initiative successfully' do
      expect{
        post :create, initiative: valid_initiative_params, format: :json
      }.to change(Initiative, :count).by(1)
    end

    it 'failed when params are not valid' do
      expect{
        post :create, initiative: invalid_initiative_params, format: :json
      }.to_not change(Initiative, :count)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company, user_type: ADMIN
  end

  def response_json(response)
    @_response_json ||= JSON.parse(response.body)
  end

  def valid_initiative_params
    attributes_for(:initiative)
  end

  def invalid_initiative_params
    {
      goal: 20_000,
      status: 'close',
      name: ''
    }
  end
end
