require 'rails_helper'

RSpec.describe Api::InvitationsController, type: :controller do
  let!(:company) { create :company }
  let(:user) { create :user }
  let(:user_params) { attributes_for :user, first_name: 'Bob', last_name: 'Dawg' }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new user with the right name and company id and sends email' do
      expect {
        expect {
          post :create, user: user_params, format: :json
          response_json = JSON.parse(response.body)
          expect(response_json['first_name']).to eq('Bob')
          expect(response_json['last_name']).to eq('Dawg')
          expect(response_json['company_id']).to eq(company.id)
        }.to change(User, :count).by(1)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
