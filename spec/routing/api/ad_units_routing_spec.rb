require "rails_helper"

RSpec.describe Api::AdUnitsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/ad_units").to route_to("api/ad_units#index")
    end

    it "routes to #new" do
      expect(:get => "/api/ad_units/new").to route_to("api/ad_units#new")
    end

    it "routes to #show" do
      expect(:get => "/api/ad_units/1").to route_to("api/ad_units#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/ad_units/1/edit").to route_to("api/ad_units#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/ad_units").to route_to("api/ad_units#create")
    end

    it "routes to #update" do
      expect(:put => "/api/ad_units/1").to route_to("api/ad_units#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/ad_units/1").to route_to("api/ad_units#destroy", :id => "1")
    end

  end
end
