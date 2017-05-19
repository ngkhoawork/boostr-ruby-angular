require 'rails_helper'

RSpec.describe Api::V2::ActivityTypesController, type: :controller do
  before do
    valid_token_auth user
  end
  
  it 'returns successful login' do
    get :index

    expect(response).to be_success
  end

  it 'returns activity types' do
    get :index

    expect(json_response.length).to be 12
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
