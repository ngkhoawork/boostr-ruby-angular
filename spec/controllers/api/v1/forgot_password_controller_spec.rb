require 'rails_helper'

RSpec.describe Api::V1::ForgotPasswordController, type: :controller do

  let(:user) { create :user }

  describe 'POST #forgot_password' do
    it 'responds with 201 and sends email instructions' do
      expect_any_instance_of(User).to receive(:send_reset_password_instructions)
      post :create, email: user.email
      expect(response).to have_http_status(:created)
    end

    it 'responds with 201 and does not send an email for invalid email addresses' do
      expect_any_instance_of(User).not_to receive(:send_reset_password_instructions)
      post :create, email: 'notreal'
      expect(response).to have_http_status(:created)
    end

    it 'responds with 400 Bad Request if no details are given' do
      post :create
      expect(response).to have_http_status(:bad_request)
    end
  end
end
