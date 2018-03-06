require 'rails_helper'

RSpec.describe Api::V2::UserTokenController, type: :controller do
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

  describe "POST #extension (copy of create with OK status)" do
    subject { post :extension, params }

    context 'when user does not exist' do
      let(:params) { { auth: { email: 'wrong@example.net', password: '' } } }

      it { subject; expect(response).to have_http_status(:not_found) }
    end

    context 'when password is invalid' do
      let(:params) { { auth: { email: user.email, password: 'wrong' } } }

      it { subject; expect(response).to have_http_status(:not_found) }
    end

    context 'when creds are valid' do
      let(:params) { { auth: { email: user.email, password: 'password' } } }

      it do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'jwt'
      end
    end
  end
end
