require 'rails_helper'

RSpec.describe ContactCfName, type: :model do
  context 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:contact_cf_options) }
  end

  context 'validations' do
    it { should validate_presence_of(:field_type) }

    context 'empty slots validation' do
      it 'is valid if there is space' do
        cf_name = build :contact_cf_name, field_type: 'note'

        expect(cf_name).to be_valid
      end

      it 'is invalid when there is no space' do
        create_list :contact_cf_name, 10, field_type: 'note', company: company

        cf_name = build :contact_cf_name, field_type: 'note', company: company

        expect(cf_name).not_to be_valid
        expect(cf_name.errors.full_messages).to eql(["Field type Note reached it's limit of 10"])
      end
    end
  end

  context 'scopes' do
    context 'by_type' do
      it 'returns subject based on type' do
        contact_cf_name(field_type: 'dropdown')

        collection = ContactCfName.by_type('dropdown')

        expect(collection).to include(contact_cf_name)
      end

      it 'does not filter by type if none given' do
        contact_cf_name(field_type: 'percentage')

        collection = ContactCfName.by_type(nil)

        expect(collection).to include(contact_cf_name)
      end
    end

    context 'by_index' do
      it 'returns subject based on index' do
        contact_cf_name(field_type: 'percentage')

        collection = ContactCfName.by_index(1)

        expect(collection).to include(contact_cf_name)
      end

      it 'does not filter by index if none given' do
        contact_cf_name(field_type: 'percentage')

        collection = ContactCfName.by_index(nil)

        expect(collection).to include(contact_cf_name)
      end
    end
  end

  context 'before_create' do
    it 'sets field_index automatically' do
      contact_cf_names(7, field_type: 'dropdown')

      expect(contact_cf_names.map(&:field_index))
      .to eql [1, 2, 3, 4, 5, 6, 7]
    end

    it 'allocates freed up slots' do
      contact_cf_names(10, field_type: 'datetime')

      new_cf = build :contact_cf_name, field_type: 'datetime', company: company

      expect(new_cf).not_to be_valid

      contact_cf_names.third.destroy

      expect(new_cf).to be_valid

      new_cf.save

      expect(new_cf.field_index).to be 3
      expect(company.contact_cf_names.pluck(:field_index))
      .to eql [1, 2, 4, 5, 6, 7, 8, 9, 10, 3]
    end
  end


  context 'after_create' do
    it 'updates company ContactCfs with field name' do
      contact_cf(note1: 2, contact: contact)

      expect(contact_cf.note1).to eql "2"

      contact_cf_name(field_type: 'note')

      expect(contact_cf.reload.note1).to eql nil
    end
  end

  def contact_cf_name(opts={})
    opts.merge! company: company
    @_contact_cf_name ||= create :contact_cf_name, opts
  end

  def contact_cf(opts={})
    opts.merge! company: company
    @_contact_cf ||= create :contact_cf, opts
  end

  def contact_cf_names(amount=2, opts={})
    opts.merge! company: company
    @_contact_cf_names ||= create_list :contact_cf_name, amount, opts
  end

  def company
    @_company ||= create :company
  end

  def contact(opts={})
    opts.merge! company: company
    @_contact ||= create :contact, opts
  end
end
