require 'rails_helper'

RSpec.describe "Api::AdUnits", type: :request do
  describe "GET /api_ad_units" do
    it "works! (now write some real specs)" do
      get api_ad_units_path
      expect(response).to have_http_status(200)
    end
  end
end
