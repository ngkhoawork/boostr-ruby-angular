require 'rails_helper'

RSpec.describe Api::V1::UserTokenController, type: :controller do
  let(:user) { create :user, password: 'password' }

  describe "POST #create" do
    it "responds with 404 if user does not exist" do
      post :create, auth: { email: 'wrong@example.net', password: '' }
      expect(response).to have_http_status(:not_found)
    end

    it "responds with 404 if password is invalid" do
      post :create, auth: { email: user.email, password: 'wrong' }
      expect(response).to have_http_status(:not_found)
    end

    it "responds with 201" do
      post :create, auth: { email: user.email, password: 'password' }
      expect(response).to have_http_status(:created)
      expect(response.body).to include 'jwt'
    end
  end
end
