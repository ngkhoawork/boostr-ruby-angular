require 'rails_helper'

RSpec.describe Api::SalesExecutionDashboardController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:user) { create :user }

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
