require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:user) { create :user }
  let(:client) { create :client }
  let(:client2) { create :client }
  let(:address) { create :address, email: 'abc123@boostrcrm.com' }
  let(:address2) { create :address, email: 'abc1234@boostrcrm.com' }

  context 'scopes' do
    context 'for_client' do
      let!(:contact) { create :contact, client: client, address: address }
      let!(:another_contact) { create :contact, address: address2, client: client2 }

      it 'returns all when client_id is nil' do
        expect(Contact.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Contact.for_client(client.id).count).to eq(1)
      end
    end
  end

  context 'validation' do
    let!(:contact) { create :contact, client: client, address: address }

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
end
