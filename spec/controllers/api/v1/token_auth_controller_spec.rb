require 'rails_helper'

RSpec.describe Api::V1::RemindersController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  it "responds with unauthorized to invalid token" do
    invalid_token_auth

    get :index

    expect(response).to have_http_status :unauthorized
  end

  it "responds with unauthorized to invalid entity" do
    invalid_entity_auth

    get :index

    expect(response).to have_http_status :unauthorized
  end

  it "responds with success if authenticated" do
    valid_token_auth user

    get :index

    expect(response).to have_http_status :success
  end

  it "has a current_user after authentication" do
    valid_token_auth user

    get :index

    expect(response).to have_http_status :success
    expect(@controller.current_user.id).to be user.id
  end

  it 'responds with unauthorized to inactive user' do
    user.update(is_active: false)
    valid_token_auth user

    get :index

    expect(response).to have_http_status :unauthorized
  end
end
