require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  let(:superadmin) { create :user, roles_mask: 4 }
  let(:user) { create :user }

  context 'as a non-superadmin user' do
    before do
      sign_in user
    end

    it 'returns a 404' do
      expect {
        get :index
      }.to raise_error(ActionController::RoutingError)
    end
  end

  context 'as an superadmin' do
    before do
      sign_in superadmin
    end

    it 'return success' do
      get :index
      expect(response.code).to eq('200')
    end
  end
end