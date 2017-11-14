require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create :company }

  context 'associations' do
    it { should have_many(:contact_cf_names) }
    it { should have_many(:contact_cfs).through(:contacts) }

    it { should have_many(:deal_custom_field_names) }
    it { should have_many(:deal_custom_fields).through(:deals) }

    it { should have_many(:deal_product_cf_names) }
    it { should have_many(:deal_product_cfs).through(:deal_products) }

    it { should have_many(:requests) }
  end

  context 'before create' do
    it 'creates default fields' do
      expect {
        create :company
      }.to change(Field, :count).by(16)
    end

    it 'creates default field options' do
      expect {
        create :company
      }.to change(Option, :count).by(3)
    end

    it 'creates Contact Role field and option' do
      contact_role_field = company.fields.find_by(subject_type: 'Deal', name: 'Contact Role', value_type: 'Option', locked: true)
      expect(contact_role_field).to be
      billing_contact_option = contact_role_field.options.find_by(name: 'Billing', company: company, locked: true)
      expect(billing_contact_option).to be
    end
  end

  describe '#validation_for' do
    it 'returns validation if company has it' do
      validation = create :validation, company: company, factor: 'Strong Validation'
      expect(company.validation_for(:strong_validation)).to eq validation
    end

    it 'returns nil if company does not have it' do
      expect(company.validation_for(:no_validation)).to eq nil
    end
  end
end
