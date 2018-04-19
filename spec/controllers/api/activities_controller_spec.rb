require 'rails_helper'

describe Api::ActivitiesController, type: :controller do
  let!(:company) { create :company }
  let(:new_company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, team: team, company: company }
  let(:client) { create :client, company: company }
  let(:deal) { create :deal, advertiser: client, company: company }
  let(:contacts) { create_list :contact, 10, clients: [client], company: company }
  let(:activity_params) { attributes_for(:activity) }
  let(:activity_with_custom_field_params) do
    activity_params.merge(custom_field_attributes: { text1: FFaker::HipsterIpsum.word })
  end
  let(:existing_activity) { create :activity, company: company }
  let(:user_contact) { create :contact, address_attributes: { email: user.email }, company: company }

  before :each do
    sign_in user
  end

  describe "POST #create" do
    it 'creates a new activity and returns success' do
      expect {
        post :create, {
          activity: activity_with_custom_field_params,
          contacts: contacts.map(&:id)
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 10
      }.to change(Activity, :count).by(1).and \
           change(CustomField, :count).by(1)
    end

    it 'filters out current user from contacts' do
      post :create, {
        activity: activity_params,
        contacts: contacts.map(&:id) + [user_contact.id]
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

      before do
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

      it 'filters out current user from contacts' do
        existing_contacts << {name: user_contact.name, address: {email: user_contact.address.email}}
        post :create, {
          activity: activity_params,
          guests: existing_contacts
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 10
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

    context 'contact last happened activity' do
      it 'update activity updated at field when value is nil' do
        contact = create :contact

        post :create, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to eq activity_params[:happened_at]
      end

      it 'update activity updated at field when value is less than activity happened at' do
        contact = create :contact, activity_updated_at: '2016-02-11 23:15:03'

        post :create, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to eq activity_params[:happened_at]
      end

      it 'does not update activity updated at field when value is greater than activity happened at' do
        contact = create :contact, activity_updated_at: '2016-04-11 23:15:03'

        post :create, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to_not eq activity_params[:happened_at]
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

    it 'filters out current user from contacts' do
      put :update, {
        id: existing_activity.id,
        activity: activity_params,
        contacts: contacts.map(&:id) + [user_contact.id]
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

      before do
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

      it 'filters out current user from contacts' do
        existing_contacts << {name: user_contact.name, address: {email: user_contact.address.email}}

        put :update, {
          id: existing_activity.id,
          activity: activity_params,
          guests: existing_contacts
        }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contacts'].length).to eq 10
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

    context 'contact last happened activity' do
      it 'update activity updated at field when value is less than activity happened at' do
        contact = create :contact, activity_updated_at: '2016-02-11 23:15:03'
        activity = create :activity

        put :update, id: activity.id, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to eq activity_params[:happened_at]
      end

      it 'update activity updated at field when value is less than activity happened at but contact has activity with happened at greater then we send' do
        contact = create :contact, activity_updated_at: '2016-04-11 23:15:03'
        first_activity = create :activity, happened_at: '2016-04-11 23:15:03'
        second_activity = create :activity, contacts: [contact], happened_at: '2016-04-01 23:15:03'

        put :update, id: first_activity.id, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to eq second_activity.happened_at
      end

      it 'does not update activity updated at field when value is greater than activity happened at' do
        contact = create :contact, activity_updated_at: '2016-04-11 23:15:03'
        activity = create :activity

        post :create, id: activity.id, activity: activity_params, contacts: [contact.id], format: :json

        expect(contact.reload.activity_updated_at).to_not eq activity_params[:happened_at]
      end
    end
  end
end
