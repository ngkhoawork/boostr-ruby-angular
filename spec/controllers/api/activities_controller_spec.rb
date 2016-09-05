require 'rails_helper'

RSpec.describe Api::ActivitiesController, type: :controller do
  let(:new_company) { create :company }
  let(:team) { create :parent_team }
  let(:user) { create :user, team: team }
  let(:client) { create :client }
  let(:deal) { create :deal, advertiser: client }
  let(:contacts) { create_list :contact, 10, client: client }
  let(:activity_params) {
    attributes_for(:activity)
  }
  let(:existing_activity) { create :activity }

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
            guests: existing_contacts
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
            guests: existing_contacts
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
            guests: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 12
          new_contacts = response_json['contacts'].select do |contact|
            contact["name"] == 'Peggy M. Castle' || contact["name"] == 'William Bernard'
          end
          expect(new_contacts.length).to eq 2
          expect(new_contacts.map {|c| c['created_by']}).to eq [user.id, user.id]
        }.to change(Activity, :count).by(1)
      end

      context 'when there are contacts with same email in other companies' do
        it 'does not return contacts from different companies' do
          duplicate_contact = new_company.contacts.create(
            name: contacts[0].name,
            address_attributes: { email: contacts[0].address.email }
          )

          expect {
            post :create, {
              activity: activity_params,
              guests: existing_contacts
            }, format: :json
            expect(response).to be_success
            response_json = JSON.parse(response.body)
            expect(response_json['contacts'].length).to eq 10
          }.to change(Activity, :count).by(1)
        end

        it 'creates new company contacts when email is already added in other companies' do
          duplicate_contact = new_company.contacts.create(
            name: 'New Duplicate',
            address_attributes: { email: 'new_duplicate@example.org' }
          )
          existing_contacts << {
            name: duplicate_contact.name,
            address: { email: duplicate_contact.address.email }
          }

          expect {
            post :create, {
              activity: activity_params,
              guests: existing_contacts
            }, format: :json
            expect(response).to be_success
            response_json = JSON.parse(response.body)
            expect(response_json['contacts'].length).to eq 11
            new_contact = response_json['contacts'].find {|c| c["name"] == duplicate_contact.name}
            expect(new_contact['name']).to eq duplicate_contact.name
            expect(new_contact['created_by']).to eq user.id
          }.to change(Activity, :count).by(1)
        end
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
        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          guests: existing_contacts
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 10
      end

      it 'does not add duplicates to the activity' do
        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          contacts: contacts.map(&:id),
          guests: existing_contacts
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 10
      end

      it 'creates new contacts out of raw data' do
        existing_contacts.concat new_contacts
        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          contacts: contacts.map(&:id),
          guests: existing_contacts
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 12
        new_contacts = response_json['contacts'].select do |contact|
          contact["name"] == 'Peggy M. Castle' || contact["name"] == 'William Bernard'
        end
        expect(new_contacts.length).to eq 2
        expect(new_contacts.map {|c| c['created_by']}).to eq [user.id, user.id]
      end

      context 'when there are contacts with same email in other companies' do
        it 'does not return contacts from different companies' do
          duplicate_contact = new_company.contacts.create(
            name: contacts[0].name,
            address_attributes: { email: contacts[0].address.email }
          )

          put :update, {
            id: existing_activity.id,
            activity: activity_params,
            guests: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 10
        end

        it 'creates new company contacts when email is already added in other companies' do
          duplicate_contact = new_company.contacts.create(
            name: 'New Duplicate',
            address_attributes: { email: 'new_duplicate@example.org' }
          )
          existing_contacts << {
            name: duplicate_contact.name,
            address: { email: duplicate_contact.address.email }
          }

          put :update, {
            id: existing_activity.id,
            activity: activity_params,
            guests: existing_contacts
          }, format: :json
          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['contacts'].length).to eq 11
          new_contact = response_json['contacts'].find {|c| c["name"] == duplicate_contact.name}
          expect(new_contact['name']).to eq duplicate_contact.name
          expect(new_contact['created_by']).to eq user.id
        end
      end
    end
  end
end
