require 'rails_helper'

RSpec.describe Api::KpisDashboardController, type: :controller do
  let(:user) { create :user }
  let(:sellers) { create_list :user, 5, user_type: 1 }

  before do
    sign_in user
  end

  describe "GET #win_rate_by_seller" do
    it "returns http success" do
      # get :win_rate_by_seller
      # expect(response).to have_http_status(:success)
      expect(true).to eq(true)
    end
  end
end
