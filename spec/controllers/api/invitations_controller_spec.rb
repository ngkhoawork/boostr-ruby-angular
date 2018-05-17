require 'rails_helper'

RSpec.describe Api::InvitationsController, type: :controller do
  let!(:company) { create :company }
  let(:user) { create :user, email: 'johnsnow@stark.com' }
  let(:new_user_params) { attributes_for :user, first_name: 'Bob', last_name: 'Dawg' }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]

    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new user with the right name and company id and sends email' do
      expect do
        expect { post :create, user: new_user_params, format: :json }.to change(User, :count).by(1)
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      response_json = JSON.parse(response.body)

      expect(response_json['first_name']).to eq('Bob')
      expect(response_json['last_name']).to eq('Dawg')
      expect(response_json['company_id']).to eq(company.id)
    end

    describe 'does not create a new user' do
      let(:not_valid_new_user_params) { new_user_params }

      subject { post :create, user: not_valid_new_user_params, format: :json }

      it 'when email has not unique' do
        not_valid_new_user_params.merge!(email: 'johnsnow@stark.com')

        expect do
          expect { subject }.not_to change(User, :count)
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end

      it 'when first name has not present' do
        not_valid_new_user_params.merge!(first_name: nil)

        expect do
          expect { subject }.not_to change(User, :count)
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end

      it 'when last name has not present' do
        not_valid_new_user_params.merge!(last_name: nil)

        expect do
          expect { subject }.not_to change(User, :count)
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end
