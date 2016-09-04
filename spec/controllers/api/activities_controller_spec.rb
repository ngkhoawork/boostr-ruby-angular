require 'rails_helper'

RSpec.describe Api::ActivitiesController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:client) { create :client, company: company }
  let(:deal) { create :deal, advertiser: client, company: company }
  let(:contacts) { create_list :contact, 10, company: company, client: client }
  let(:activity_params) {
    attributes_for(:activity)
  }
  let(:existing_activity) { create :activity, company: company }

  before do
    sign_in user
  end

  describe "POST #create" do
    it 'creates a new activity and returns success' do
      expect {
        post :create, {
          activity: activity_params,
          contacts: contacts.map(&:id)
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to be 10
      }.to change(Activity, :count).by(1)
    end
  end

  describe "PUT #update" do
    it 'creates a new activity and returns success' do
      put :update, {
        id: existing_activity.id,
        activity: activity_params,
        contacts: contacts.map(&:id)
      }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['contacts'].length).to be 10
    end
  end
end
