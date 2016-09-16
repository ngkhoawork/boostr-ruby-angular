require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:company) { Company.first }
  let(:user) { create :user }

  context 'phone number' do
    it 'is stripped and stored as an integer' do
      address = Address.create(phone: '(208) 867-5309')

      expect(address.phone).to eq('2088675309')
    end
  end

  context 'mobile number' do
    it 'is stripped and stored as an integer' do
      address = Address.create(mobile: '(208) 867-5309')

      expect(address.mobile).to eq('2088675309')
    end
  end

  context 'scopes' do
    context 'contacts_by_email' do
      let!(:contacts) { create_list :contact, 2, company: company }

      it 'returns one address based on an email' do
        address = Address.contacts_by_email(contacts[0].address.email)
        expect(address.length).to eq(1)
      end

      it 'returns addresses based on an array of emails' do
        addresses = Address.contacts_by_email(contacts.map(&:address).map(&:email))
        expect(addresses.length).to eq(2)
      end
    end
  end
end
