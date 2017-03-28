require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:user) { create :user }
  let(:client) { create :client }
  let(:client2) { create :client }
  let(:address) { create :address, email: 'abc123@boostrcrm.com' }
  let(:address2) { create :address, email: 'abc1234@boostrcrm.com' }

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

  context 'associations' do
    it { should have_many(:deals).through(:deal_contacts) }
    it { should have_many(:deal_contacts) }
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
        contacts = Contact.by_client_ids(10, 0, [client.id, client2.id])
        expect(contacts.length).to eq(client_contacts.count)
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
end
