require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  let(:user) { create :user }

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code if the user is not logged in" do
      sign_in user

      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "redirects to the dashboard if the user is logged in" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end
  end

  context 'token auth' do
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
      valid_token_auth(user)
      get :index
      expect(response).to have_http_status :success
    end

    it "has a current_user after authentication" do
      valid_token_auth(user)
      get :index
      expect(response).to have_http_status :success
      assert @controller.current_user.id == user.id
    end
  end
end
