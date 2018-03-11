require 'rails_helper'

RSpec.describe Contact, type: :model do
  let!(:company) { create :company, :fast_create_company }
  let(:user) { create :user }
  let(:client) { create :client }
  let(:client2) { create :client }
  let(:address) { create :address, email: 'abc123@boostrcrm.com' }
  let(:address2) { create :address, email: 'abc1234@boostrcrm.com' }

  context 'associations' do
    it { should have_many(:deals).through(:deal_contacts) }
    it { should have_many(:deal_contacts) }
    it { should have_one :contact_cf }

    it 'has one latest_happened_activity' do
      contact = create :contact
      create :activity, contacts: [contact], happened_at: DateTime.now - 1.month
      activity = create :activity, contacts: [contact], happened_at: DateTime.now

      expect(contact.latest_happened_activity.count).to be 1
      expect(contact.latest_happened_activity.first).to eq activity
    end

    it 'has many non_primary_clients' do
      contact = create :contact, clients: [client, client2]

      expect(contact.non_primary_clients.order(:name)).to eq(contact.clients.order(:name))
    end
  end

  context 'after_save' do
    let(:contact) { build :contact, client_id: client.id }

    it 'creates a relation with primary flag when contact is created' do
      expect {
        contact.save
      }.to change(ClientContact, :count).by(1)
      relation = ClientContact.last
      expect(relation.contact_id).to eq contact.id
      expect(relation.client_id).to eq contact.client_id
      expect(relation.primary).to eq true
    end

    it 'creates a relation without primary flag on contact update' do
      contact.save
      contact.client_id = client2.id
      expect {
        contact.save
      }.to change(ClientContact, :count).by(1)
      relation = ClientContact.last
      expect(relation.contact_id).to eq contact.id
      expect(relation.client_id).to eq contact.client_id
      expect(relation.primary).to eq false
    end

    it 'does not modify primary flag to false for primary clients' do
      contact.save
      contact.client_id = client2.id
      contact.save
      contact.client_id = client.id
      contact.save
      relation = ClientContact.where(contact_id: contact.id, client_id: client.id).first
      expect(relation.primary).to eq true
    end

    it 'resets client contact relation if client_id is set to nil' do
      contact.save
      contact.client_id = nil
      contact.save
      expect(contact.clients.length).to eq 0
    end
  end

  context 'scopes' do
    context 'unassigned' do
      let!(:contact) { create :contact, clients: [client], address: address }
      let!(:another_contact) { create :contact, clients: [client2] }
      let!(:unassigned_contact) { create :contact, clients: [] }

      it 'returns unassigned contact' do
        expect(Contact.unassigned(nil).count).to eq(1)
      end
    end

    context 'by_email' do
      let!(:user_contact) { create :contact, name: 'user contact', address_attributes: { email: user.email } }

      it 'returns a contact based on email address' do
        contact_array = Contact.by_email(user.email, user.company_id)
        expect(contact_array.length).to eq(1)
        expect(contact_array.first.name).to eq(user_contact.name)
        expect(contact_array.first.address.email).to eq(user_contact.address.email)
      end
    end

    context 'total_count' do
      let!(:some_contacts) { create_list :contact, 15 }

      it 'ignores limit and offset and returns a total count' do
        contacts = Contact.all.limit(3).offset(5)
        expect(contacts.total_count).to eq(some_contacts.count.to_s)
      end
    end

    context 'by_client_ids' do
      let!(:some_contacts) { create_list :contact, 3 }
      let!(:client_contacts) { create_list :contact, 3, clients: [client, client2] }

      it 'returns contacts that have given clients ids assigned as clients' do
        contacts = Contact.by_client_ids([client.id, client2.id])
        expect(contacts.length).to eq(client_contacts.count)
      end
    end

    context 'by_primary_client' do
      let(:client) { create :client, name: 'Flipboard' }
      let!(:some_contacts) { create_list :contact, 3 }
      let!(:client_contacts) { create_list :contact, 3, clients: [client], client_id: client.id }

      it 'returns contacts working at given client name' do
        contacts = Contact.by_primary_client_name('Flipboard')

        expect(contacts.length).to be 3
      end

      it 'does case insensitive search' do
        contacts = Contact.by_primary_client_name('flipboard')

        expect(contacts.length).to be 3
      end

      it 'skips the scope if parameter is empty' do
        contacts = Contact.by_primary_client_name('')

        expect(contacts.length).to be 6
      end
    end

    context 'by_city' do
      let!(:luxury_contact) { create :contact, address_attributes: { city: 'Palm Beach', email: FFaker::Internet.email } }
      let!(:misc_contacts) { create_list :contact, 3, clients: [client], client_id: client.id }

      it 'finds contacts by city' do
        contacts = Contact.by_city('Palm Beach')

        expect(contacts.length).to be 1
      end

      it 'does case insensitive search' do
        contacts = Contact.by_city('palm beach')

        expect(contacts.length).to be 1
      end

      it 'skips the scope if parameter is empty' do
        contacts = Contact.by_city('')

        expect(contacts.length).to be 4
      end
    end

    context 'by job level' do
      let!(:field) { company.fields.find_or_initialize_by(subject_type: 'Contact', name: 'Job Level', value_type: 'Option', locked: true) }
      let!(:pro) { create :option, name: 'Pro', field: field }
      let!(:rookie) { create :option, name: 'Rookie', field: field }
      let!(:new_contacts) { create_list :contact, 3, values_attributes: [{ field_id: field.id, option_id: rookie.id }]}
      let!(:pro_contacts) { create_list :contact, 3, values_attributes: [{ field_id: field.id, option_id: pro.id }]}

      it 'finds contacts by job level' do
        contacts = Contact.by_job_level('Rookie')

        expect(contacts.length).to be 3
      end
    end
  end

  context 'validation' do
    let!(:contact) { create :contact, clients: [client], address: address }

    it 'allows to create contacts with same email across companies' do
      duplicate = build(:contact, address: contact.address)
      expect(duplicate).to be_valid
    end

    it 'validates email uniqueness within a company' do
      duplicate = build(:contact, address: contact.address)
      duplicate.company_id = contact.company_id
      expect(duplicate).not_to be_valid
      expect(duplicate.errors["email"]).to eq(['has already been taken'])
    end
  end

  describe 'primary_client' do
    let!(:contact) { create :contact, client_id: client.id }

    it 'returns the primary client' do
      expect(contact.primary_client).to eq(client)
    end
  end

  describe 'update_primary_client' do
    let!(:contact) { create :contact, client_id: client.id }

    it 'updates the primary client and removes previous relation' do
      expect(contact.primary_client).to eq(client)
      contact.client_id = client2.id
      contact.save
      contact.update_primary_client
      expect(contact.reload.primary_client).to eq(client2)
      expect(contact.clients).to eq([client2])
    end
  end

  describe 'metadata' do
    let(:client) { create :client, name: 'Flipboard' }
    let(:client2) { create :client, name: 'Facebook' }

    let!(:field) { company.fields.find_by(subject_type: 'Contact', name: 'Job Level') }
    let!(:pro) { create :option, name: 'CEO', field: field }
    let!(:rookie) { create :option, name: 'Seller', field: field }

    let!(:pro_contact) { create :contact,
      clients: [client], client_id: client.id,
      values_attributes: [{ field_id: field.id, option_id: rookie.id }],
      address_attributes: (attributes_for :address, city: 'Palm Beach')
    }

    let!(:rookie_contact) { create :contact,
      clients: [client2], client_id: client2.id,
      values_attributes: [{ field_id: field.id, option_id: pro.id }],
      address_attributes: (attributes_for :address, city: 'New York')
    }

    xit 'returns information about possible contact filters' do
      metadata = Contact.metadata(company.id)

      expect(metadata[:workplaces]).to include 'Facebook'
      expect(metadata[:workplaces]).to include 'Flipboard'
      expect(metadata[:job_levels]).to include 'CEO'
      expect(metadata[:job_levels]).to include 'Seller'
      expect(metadata[:cities]).to include 'Palm Beach'
      expect(metadata[:cities]).to include 'New York'
      expect(metadata[:countries]).to include 'Ukraine'
      expect(metadata[:countries]).to include 'France'
    end
  end
end
