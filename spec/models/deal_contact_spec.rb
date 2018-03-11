require 'rails_helper'

RSpec.describe DealContact, type: :model do
  let!(:company) { create :company }

  context 'associations' do
    it { should belong_to(:contact) }
    it { should belong_to(:deal) }
  end

  context 'validations' do
    context 'billing contact uniqueness' do
      let(:billing_contact) { create :deal_contact, role: 'Billing' }

      it 'validates that billing contact is unique on a deal' do
        expect(billing_contact).to be_valid
      end

      it 'fails new contacts if there is another billing contact on a deal' do
        new_contact = build :deal_contact, role: 'Billing', deal: billing_contact.deal
        expect(new_contact).not_to be_valid
        expect(new_contact.errors.full_messages).to eq(['Role Only one billing contact allowed'])
      end

      it 'prohibits changing role to billing for existing contacts if another billing contact exists' do
        new_contact = create :deal_contact, role: nil, deal: billing_contact.deal
        expect(new_contact).to be_valid
        new_contact.update(role: 'Billing')
        expect(new_contact.errors.full_messages).to eq(['Role Only one billing contact allowed'])
      end
    end

    context 'full billing address validation' do
      let(:deal_contact) { create :deal_contact, role: nil }
      let(:billing_validation) { Validation.find_by(factor: 'Billing Contact Full Address', company: deal_contact.deal.company) }
      let(:address_without_street) { create(:address, street1: nil) }
      let(:full_address) { create(:address) }
      let(:contact_with_full_address) { create(:contact, address: full_address) }
      let(:contact_without_full_address) { create(:contact, address: address_without_street) }

      it 'fails when billing address is not full' do
        billing_validation.criterion.update_attribute(:value_boolean, true)
        billing_contact = build :deal_contact, role: 'Billing', contact: contact_without_full_address
        expect(billing_contact).not_to be_valid
      end

      it 'updates deal contact to billing when address is full' do
        billing_validation.criterion.update_attribute(:value_boolean, true)
        billing_contact = create :deal_contact, role: 'Billing', contact: contact_with_full_address
        expect(billing_contact).to be_valid
      end
    end
  end
end
