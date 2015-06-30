require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  let(:user) { create :user }

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code if the user is not logged in" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "redirects to the dashboard if the user is logged in" do
      sign_in user

      get :index
      expect(response).to redirect_to(dashboard_path)
      expect(response).to have_http_status(302)
    end
  end

  describe "GET #dashboard" do
    it "redirects to login if the user is not logged in" do
      get :dashboard
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(302)
    end

    it "responds successfully with an HTTP 200 status code if the user is logged in" do
      sign_in user

      get :dashboard
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end