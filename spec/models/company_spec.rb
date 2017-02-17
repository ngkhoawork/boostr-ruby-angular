require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create :company }

  context 'before create' do
    it 'creates default fields' do
      expect {
        create :company
      }.to change(Field, :count).by(11)
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
end
