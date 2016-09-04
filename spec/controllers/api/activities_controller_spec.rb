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
        expect(response_json['contacts'].length).to eq 10
      }.to change(Activity, :count).by(1)
    end

    context 'when contacts are sent as objects' do
      let(:existing_contacts) { [] }
      let(:new_contacts) {
        [
          { name: 'Peggy M. Castle', address: { email: 'PeggyMCastle@rhyta.com' } },
          { name: 'William Bernard', address: { email: 'WilliamBBernard@jourrapide.com' } }
        ]
      }

      before(:each) do
        contacts.each do |contact|
          existing_contacts << {name: contact.name, address: {email: contact.address.email}}
        end
      end

      it 'finds existing contacts based on email address' do
        expect {
          post :create, {
            activity: activity_params,
            raw_contact_data: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 10
        }.to change(Activity, :count).by(1)
      end

      it 'does not add duplicates to the activity' do
        expect {
          post :create, {
            activity: activity_params,
            contacts: contacts.map(&:id),
            raw_contact_data: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 10
        }.to change(Activity, :count).by(1)
      end

      it 'creates new contacts out of raw data' do
        existing_contacts.concat new_contacts
        expect {
          post :create, {
            activity: activity_params,
            contacts: contacts.map(&:id),
            raw_contact_data: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 12
          new_contacts = response_json['contacts'].select do |contact|
            contact["name"] == 'Peggy M. Castle' || contact["name"] == 'William Bernard'
          end
          expect(new_contacts.length).to eq 2
        }.to change(Activity, :count).by(1)
      end
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
      expect(response_json['contacts'].length).to eq 10
    end
  end
end
