require 'rails_helper'

RSpec.describe DealContact, type: :model do
  context 'associations' do
    it { should belong_to(:contact) }
    it { should belong_to(:deal) }
  end

  context 'validations' do
    context 'role - billing' do
      let(:billing_contact) { create :deal_contact, role: 'Billing' }

      it 'validates presence of street' do
        billing_contact.contact.address.street1 = nil
        expect(billing_contact).not_to be_valid
        expect(billing_contact.errors['role']).to eq(['Billing contact requires street, city, country and Zip code'])
      end

      it 'validates presence of city' do
        billing_contact.contact.address.city = nil
        expect(billing_contact).not_to be_valid
        expect(billing_contact.errors['role']).to eq(['Billing contact requires street, city, country and Zip code'])
      end

      it 'validates presence of country' do
        billing_contact.contact.address.country = nil
        expect(billing_contact).not_to be_valid
        expect(billing_contact.errors['role']).to eq(['Billing contact requires street, city, country and Zip code'])
      end

      it 'validates presence of zip code' do
        billing_contact.contact.address.zip = nil
        expect(billing_contact).not_to be_valid
        expect(billing_contact.errors['role']).to eq(['Billing contact requires street, city, country and Zip code'])
      end
    end
  end
end
