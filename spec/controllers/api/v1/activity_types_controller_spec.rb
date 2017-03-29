require 'rails_helper'

RSpec.describe Api::V1::ActivityTypesController, type: :controller do
  before do
    sign_in user
  end
  
  it 'returns successful login' do
    get :index

    expect(response).to be_success
  end

  xit 'lists activity types' do
    get :index

    expect(response).to eq true
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
