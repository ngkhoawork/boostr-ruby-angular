require 'rails_helper'

RSpec.describe DealContact, type: :model do
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
  end
end
