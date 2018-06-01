require 'rails_helper'

RSpec.describe CustomFieldName, type: :model do
  describe 'validations' do
    describe 'presence' do
      it 'valid when field_type present' do
        expect(build_custom_field_name(field_type: 'text')).to be_valid
      end

      it 'not valid when field_type absent' do
        expect(build_custom_field_name(field_type: nil)).not_to be_valid
      end
    end

    describe 'uniqueness' do
      it 'valid with uniq position' do
        create_custom_field_name(position: 1)

        expect(build_custom_field_name(position: 2)).to be_valid
      end

      it 'not valid with not uniq position' do
        create_custom_field_name(position: 1)

        expect(build_custom_field_name(position: 1)).not_to be_valid
      end
    end

    describe 'numericality' do
      it 'valid when position is numericality' do
        expect(build_custom_field_name(position: 1)).to be_valid
      end

      it 'not valid when position is not numericality' do
        expect(build_custom_field_name(position: 'first')).not_to be_valid
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def create_custom_field_name(attrs = {})
    create :custom_field_name, company: company, **attrs
  end

  def build_custom_field_name(attrs = {})
    build :custom_field_name, company: company, **attrs
  end
end
