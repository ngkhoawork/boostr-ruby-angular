require 'rails_helper'

RSpec.describe SpendAgreementCustomFieldName, type: :model do
  context 'associations' do
    it { should belong_to(:company) }
  end

  context 'validations' do
    it { should validate_presence_of(:field_type) }

    context 'empty slots validation' do
      it 'is valid if there is space' do
        sp_cfn = build :spend_agreement_custom_field_name, field_type: 'note', company: company

        expect(sp_cfn).to be_valid
      end

      it 'is invalid when there is no space' do
        create_list :spend_agreement_custom_field_name, 10, field_type: 'note', company: company

        sp_cfn = build :spend_agreement_custom_field_name, field_type: 'note', company: company

        expect(sp_cfn).not_to be_valid
        expect(sp_cfn.errors.full_messages).to eql(["Field type Note reached it's limit of 10"])
      end
    end
  end

  context 'scopes' do
    context 'by_type' do
      it 'returns subject based on type' do
        spend_agreement_custom_field_name(field_type: 'dropdown')

        collection = SpendAgreementCustomFieldName.by_type('dropdown')

        expect(collection).to include(spend_agreement_custom_field_name)
      end

      it 'does not filter by type if none given' do
        spend_agreement_custom_field_name(field_type: 'percentage')

        collection = SpendAgreementCustomFieldName.by_type(nil)

        expect(collection).to include(spend_agreement_custom_field_name)
      end
    end

    context 'by_index' do
      it 'returns subject based on index' do
        spend_agreement_custom_field_name(field_type: 'percentage')

        collection = SpendAgreementCustomFieldName.by_index(1)

        expect(collection).to include(spend_agreement_custom_field_name)
      end

      it 'does not filter by index if none given' do
        spend_agreement_custom_field_name(field_type: 'percentage')

        collection = SpendAgreementCustomFieldName.by_index(nil)

        expect(collection).to include(spend_agreement_custom_field_name)
      end
    end
  end

  context 'before_create' do
    it 'sets field_index automatically' do
      spend_agreement_custom_field_names(7, field_type: 'dropdown')

      expect(spend_agreement_custom_field_names.map(&:field_index))
      .to eql [1, 2, 3, 4, 5, 6, 7]
    end

    it 'allocates freed up slots' do
      spend_agreement_custom_field_names(10, field_type: 'datetime')

      new_cf = build :spend_agreement_custom_field_name, field_type: 'datetime', company: company

      expect(new_cf).not_to be_valid

      SpendAgreementCustomFieldName.for_company(company.id).find_by_field_index(3).destroy

      expect(new_cf).to be_valid

      new_cf.save

      expect(new_cf.field_index).to be 3
    end
  end


  context 'after_create' do
    it 'updates company ContactCfs with field name' do
      contact_cf(note1: 2, contact: contact)

      expect(contact_cf.note1).to eql "2"

      spend_agreement_custom_field_name(field_type: 'note')

      expect(contact_cf.reload.note1).to eql nil
    end
  end

  def spend_agreement_custom_field_name(opts={})
    opts.merge! company: company
    @_spend_agreement_custom_field_name ||= create :spend_agreement_custom_field_name, opts
  end

  def contact_cf(opts={})
    opts.merge! company: company
    @_contact_cf ||= create :contact_cf, opts
  end

  def spend_agreement_custom_field_names(amount=2, opts={})
    opts.merge! company: company
    @_spend_agreement_custom_field_names ||= create_list :spend_agreement_custom_field_name, amount, opts
  end

  def company
    @_company ||= create :company
  end

  def contact(opts={})
    opts.merge! company: company
    @_contact ||= create :contact, opts
  end
end
