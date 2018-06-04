require 'rails_helper'

describe PublisherCustomFieldName do
  describe 'Validations' do
    describe 'presence' do
      it 'valid with valid attributes' do
        expect(build_publisher_custom_field_name).to be_valid
      end
  
      it 'not valid without field_label' do
        expect(build_publisher_custom_field_name(field_label: nil)).not_to be_valid
      end
  
      it 'not valid without position' do
        expect(build_publisher_custom_field_name(position: nil)).not_to be_valid
      end
    end

    describe 'uniqueness' do
      it 'valid with uniq position' do
        build_publisher_custom_field_name(position: 1)

        expect(build_publisher_custom_field_name(position: 2)).to be_valid
      end

      it 'valid with non uniq position in different companies' do
        create_publisher_custom_field_name(position: 1)

        new_custom_field = build_publisher_custom_field_name(position: 1, company: create(:company))

        expect(new_custom_field).to be_valid
      end

      it 'not valid with non uniq position in one company' do
        create_publisher_custom_field_name(position: 1)

        expect(build_publisher_custom_field_name(position: 1)).not_to be_valid
      end
    end

    describe 'numericality' do
      it 'valid when position is numericality' do
        expect(build_publisher_custom_field_name(position: 1)).to be_valid
      end

      it 'not valid when position is not numericality' do
        expect(build_publisher_custom_field_name(position: 'first')).not_to be_valid
      end
    end

    describe 'amount of custom fields by field type' do
      it 'valid when field limit has not exceeded' do
        create_publisher_custom_field_names(4, field_type: 'text')

        expect(build_publisher_custom_field_name(field_type: 'text')).to be_valid
      end

      it 'not valid when field limit has exceeded' do
        create_publisher_custom_field_names(5, field_type: 'text')

        expect(build_publisher_custom_field_name(field_type: 'text')).not_to be_valid
      end
    end

    describe 'before create' do
      describe 'assign index' do
        it 'by automatically' do
          cf_names = create_publisher_custom_field_names(3, field_type: 'text')

          expect(cf_names.map(&:field_index)).to eql([1, 2, 3])
        end

        it 'set to the free index' do
          cf_names = create_publisher_custom_field_names(3, field_type: 'text')

          cf_names.second.destroy

          expect(create_publisher_custom_field_name(field_type: 'text').field_index).to eql(2)
        end
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def create_publisher_custom_field_name(attrs = {})
    create :publisher_custom_field_name, company: company, **attrs
  end

  def create_publisher_custom_field_names(count, attrs = {})
    create_list :publisher_custom_field_name, count, company: company, **attrs
  end

  def build_publisher_custom_field_name(attrs = {})
    build :publisher_custom_field_name, company: company, **attrs
  end
end
