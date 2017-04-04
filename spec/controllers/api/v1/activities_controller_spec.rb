require 'rails_helper'

RSpec.describe Api::V1::ActivitiesController, type: :controller do
  let(:new_company) { create :company }
  let(:activity_params) {
    attributes_for(:activity)
  }
  let(:existing_activity) { create :activity, company: company, deal: nil, client: nil }
  let(:user_contact) { create :contact, address_attributes: { email: user.email } }
  let(:contacts) { create_list :contact, 10, clients: [client], company: company }

  before do
    valid_token_auth user
  end

  describe 'index' do
    it 'responds correctly' do
      get :index

      expect(response).to be_success
    end

    it 'returns list of contact\'s activities' do
      activities(contacts: [contact], deal: nil, client: nil)

      get :index, contact_id: contact.id

      expect(json_response.length).to be 15
    end

    it 'returns all activities for execs' do
      activities(deal: deal, client: client, user: nil)
      user.update(user_type: EXEC)

      get :index, page: 2, filter: 'client'

      expect(user.activities.count).to be 0
      expect(json_response.length).to be 5
    end

    it 'returns client activities from clients related to team members for team leaders' do
      team = create :team, leader: user, company: company
      another_user = create :user, company: company, team: team
      create :client_member, client: client, user: another_user
      activities(deal: deal, client: client)

      get :index, page: 2, filter: 'client'

      expect(user.activities.count).to be 0
      expect(json_response.length).to be 5
    end

    it 'returns activities created by team members' do
      team = create :team, leader: user, company: company
      another_user = create :user, company: company, team: team
      act = create :activity, user: another_user, deal: deal, company: company, comment: 'Psst'

      get :index, page: 1, filter: 'client'

      expect(user.activities.count).to be 0
      expect(json_response.length).to be 1
    end

    it 'returns nothing for sellers without activities and no client activities' do
      get :index, page: 1, filter: 'client'

      expect(user.activities.count).to be 0
      expect(json_response.length).to be 0
    end

    it 'returns activity created by user' do
      activities(deal: deal, client: client, user: user)

      get :index, page: 2, filter: 'client'

      expect(user.activities.count).to be 15
      expect(json_response.length).to be 5
    end

    it 'returns activities from clients where user is a client member' do
      activities(deal: deal, client: client)
      create :client_member, client: client, user: user

      get :index, page: 2, filter: 'client'

      expect(user.activities.count).to be 0
      expect(json_response.length).to be 5
    end
  end

  describe "POST #create" do
    it 'creates a new activity and returns success' do
      expect {
        post :create, {
          activity: activity_params,
          contacts: contacts.map(&:id)
        }, format: :json

        expect(response).to be_success
        expect(json_response['contacts'].length).to eq 10
      }.to change(Activity, :count).by(1)
    end

    it 'filters out current user from contacts' do
      post :create, {
        activity: activity_params,
        contacts: contacts.map(&:id) + [user_contact.id]
      }, format: :json

      expect(response).to be_success
      expect(json_response['contacts'].length).to eq 10
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
          expect(json_response['contacts'].length).to eq 10
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
          expect(json_response['contacts'].length).to eq 10
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
          expect(json_response['contacts'].length).to eq 12

          new_contacts = json_response['contacts'].select do |contact|
            contact["name"] == 'Peggy M. Castle' || contact["name"] == 'William Bernard'
          end

          expect(new_contacts.length).to eq 2
          expect(new_contacts.map {|c| c['created_by']}).to eq [user.id, user.id]
        }.to change(Activity, :count).by(1)
      end

      it 'filters out current user from contacts' do
        existing_contacts << {name: user_contact.name, address: {email: user_contact.address.email}}

        post :create, {
          activity: activity_params,
          guests: existing_contacts
        }, format: :json

        expect(response).to be_success
        expect(json_response['contacts'].length).to eq 10
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
            expect(json_response['contacts'].length).to eq 10
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
            expect(json_response['contacts'].length).to eq 11

            new_contact = json_response['contacts'].find {|c| c["name"] == duplicate_contact.name}

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
      expect(json_response['contacts'].length).to eq 10
    end

    it 'filters out current user from contacts' do
      put :update, {
        id: existing_activity.id,
        activity: activity_params,
        contacts: contacts.map(&:id) + [user_contact.id]
      }, format: :json

      expect(response).to be_success
      expect(json_response['contacts'].length).to eq 10
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
        expect(json_response['contacts'].length).to eq 10
      end

      it 'does not add duplicates to the activity' do
        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          contacts: contacts.map(&:id),
          guests: existing_contacts
        }, format: :json

        expect(response).to be_success
        expect(json_response['contacts'].length).to eq 10
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
        expect(json_response['contacts'].length).to eq 12

        new_contacts = json_response['contacts'].select do |contact|
          contact["name"] == 'Peggy M. Castle' || contact["name"] == 'William Bernard'
        end

        expect(new_contacts.length).to eq 2
        expect(new_contacts.map {|c| c['created_by']}).to eq [user.id, user.id]
      end

      it 'filters out current user from contacts' do
        existing_contacts << {name: user_contact.name, address: {email: user_contact.address.email}}

        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          guests: existing_contacts
        }, format: :json

        expect(response).to be_success
        expect(json_response['contacts'].length).to eq 10
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
          expect(json_response['contacts'].length).to eq 10
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
          expect(json_response['contacts'].length).to eq 11

          new_contact = json_response['contacts'].find {|c| c["name"] == duplicate_contact.name}

          expect(new_contact['name']).to eq duplicate_contact.name
          expect(new_contact['created_by']).to eq user.id
        end
      end
    end
  end

  def activities(opts={})
    opts.merge!(company: company)
    @_activities ||= create_list :activity, 15, opts
  end

  def contact
    @_contact ||= create :contact, company: company
  end

  def company
    @_company ||= create :company
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def client
    @_client ||= create :client, company: company
  end

  def user
    @_user ||= create :user, company: company
  end
end
