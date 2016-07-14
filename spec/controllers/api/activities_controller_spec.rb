require 'rails_helper'

RSpec.describe Api::ActivitiesController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:client) { create :client, company: company }
  let(:deal) { create :deal, advertiser: client, company: company }
  let(:contact) { create :contact, company: company, client: client }
  let(:activity_params) {
    attributes_for(:activity)
  }

  before do
    sign_in user
  end

  describe "POST #create" do
    it 'creates a new activity and returns success' do
      expect {
        post :create, {
          activity: activity_params,
          contacts: [contact.id]
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].first['id']).to eq(contact.id)
      }.to change(Activity, :count).by(1)
    end
  end
end
