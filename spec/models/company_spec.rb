require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create :company_with_defaults }

  context 'associations' do
    it { should have_many(:contact_cf_names) }
    it { should have_many(:contact_cfs).through(:contacts) }

    it { should have_many(:deal_custom_field_names) }
    it { should have_many(:deal_custom_fields).through(:deals) }

    it { should have_many(:deal_product_cf_names) }
    it { should have_many(:deal_product_cfs).through(:deal_products) }

    it { should have_many(:requests) }

    it { should have_many(:google_sheets_configurations) }
  end

  context 'before create' do
    it 'creates default fields' do
      expect {
        create :company_with_defaults
      }.to change(Field, :count).by(23)
    end

    it 'creates default field options' do
      expect {
        create :company_with_defaults
      }.to change(Option, :count).by(4)
    end

    it 'creates Contact Role field and option' do
      contact_role_field = company.fields.find_by(subject_type: 'Deal', name: 'Contact Role', value_type: 'Option', locked: true)
      expect(contact_role_field).to be
      billing_contact_option = contact_role_field.options.find_by(name: 'Billing', company: company, locked: true)
      expect(billing_contact_option).to be
    end

    context 'default activity types' do
      it 'creates default activity types' do
        expect {
          create :company_with_defaults
        }.to change(ActivityType, :count).by(12)
      end

      it 'assigns defult activity type values' do
        company = create :company_with_defaults

        expect(company.activity_types.by_name('Email').last).to have_attributes(
          action:'emailed to',
          icon:'/assets/icons/email.png',
          position: 10,
          editable: false,
          css_class: 'bstr-email'
        )
      end
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
