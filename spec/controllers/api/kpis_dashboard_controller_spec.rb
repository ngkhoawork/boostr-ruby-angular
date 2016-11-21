require 'rails_helper'

RSpec.describe Api::KpisDashboardController, type: :controller do
  let(:user) { create :user }
  let(:sellers) { create_list :user, 5, user_type: 1 }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
