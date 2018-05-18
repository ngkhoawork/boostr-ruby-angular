require 'rails_helper'

RSpec.describe ContactCfName, type: :model do
  context 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:contact_cf_options) }
  end

  context 'validations' do
    describe 'presence' do
      it 'valid when field_type present' do
        expect(build_contact_custom_field_name(field_type: 'text')).to be_valid
      end

      it 'not valid when field_type absent' do
        expect(build_contact_custom_field_name(field_type: nil)).not_to be_valid
      end
    end

    describe 'uniqueness' do
      it 'valid with uniq position' do
        contact_cf_name(position: 1)

        expect(build_contact_custom_field_name(position: 2)).to be_valid
      end

      it 'valid with non uniq position in different companies' do
        contact_cf_name(position: 1)

        new_custom_field = build_contact_custom_field_name(position: 1, company: create(:company))

        expect(new_custom_field).to be_valid
      end

      it 'not valid with not uniq position in one company' do
        contact_cf_name(position: 1)

        expect(build_contact_custom_field_name(position: 1)).not_to be_valid
      end
    end

    describe 'numericality' do
      it 'valid when position is numericality' do
        expect(build_contact_custom_field_name(position: 1)).to be_valid
      end

      it 'not valid when position is not numericality' do
        expect(build_contact_custom_field_name(position: 'first')).not_to be_valid
      end
    end

    describe 'amount of custom fields by field type' do
      it 'valid when field limit has not exceeded' do
        contact_cf_names(9, field_type: 'text')

        expect(build_contact_custom_field_name(field_type: 'text')).to be_valid
      end

      it 'not valid when field limit has exceeded' do
        contact_cf_names(10, field_type: 'text')
        cf_name = build_contact_custom_field_name(field_type: 'text')

        expect(cf_name).not_to be_valid
        expect(cf_name.errors.full_messages).to eql(["Field type Text reached it's limit of 10"])
      end
    end

    describe 'field type permitted' do
      it 'valid when field type present in our list' do
        expect(build_contact_custom_field_name(field_type: 'text')).to be_valid
      end

      it 'not valid when field type present but do not exist in our list' do
        expect(build_contact_custom_field_name(field_type: 'string')).not_to be_valid
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

  describe 'before create' do
    describe 'assign index' do
      it 'by automatically' do
        cf_names = contact_cf_names(3, field_type: 'text')

        expect(cf_names.map(&:field_index)).to eql([1, 2, 3])
      end

      it 'set to the free index' do
        cf_names = contact_cf_names(3, field_type: 'text')

        cf_names.second.destroy

        expect(contact_cf_name(field_type: 'text').field_index).to eql(2)
      end
    end
  end

  context 'after_create' do
    it 'updates company ContactCfs with field name' do
      contact_cf(note1: 2, contact: contact)

      expect(contact_cf.note1).to eql '2'

      contact_cf_name(field_type: 'note')

      expect(contact_cf.reload.note1).to eql nil
    end
  end

  def contact_cf(attrs = {})
    @_contact_cf ||= create :contact_cf, company: company, **attrs
  end

  def build_contact_custom_field_name(attrs = {})
    build :contact_cf_name, company: company, **attrs
  end

  def contact_cf_name(attrs = {})
    @_contact_cf_name ||= create :contact_cf_name, company: company, **attrs
  end

  def contact_cf_names(amount = 2, attrs = {})
    @_contact_cf_names ||= create_list :contact_cf_name, amount, company: company, **attrs
  end

  def company
    @_company ||= create :company
  end

  def contact(attrs = {})
    create :contact, company: company, **attrs
  end
end
