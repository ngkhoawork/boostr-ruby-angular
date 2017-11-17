require 'rails_helper'

describe 'PublisherCustomFieldName' do
  describe 'Validations' do
    context 'presence' do
      it 'valid with valid attributes' do
        expect(publisher_custom_field_name).to be_valid
      end
  
      it 'not valid without field_label' do
        expect(publisher_custom_field_name(field_label: nil)).not_to be_valid
      end
  
      it 'not valid without position' do
        expect(publisher_custom_field_name(position: nil)).not_to be_valid
      end
    end

    context 'uniqueness' do
      it 'valid with uniq position' do
        publisher_custom_field_name(position: 1)

        expect(publisher_custom_field_name(position: 2)).to be_valid
      end

      it 'not valid with non uniq position' do
        publisher_custom_field_name(position: 1).save

        expect(publisher_custom_field_name(position: 1)).not_to be_valid
      end
    end

    context 'numericality' do
      it 'valid with numeric value' do
        expect(publisher_custom_field_name(position: 1)).to be_valid
      end

      it 'not valid with non numeric value' do
        expect(publisher_custom_field_name(position: 'one')).not_to be_valid
      end
    end

    context 'amount_of_custom_fields_per_type' do
      it 'valid with proper amount of custom field per type' do
        expect(publisher_custom_field_name(field_type: 'boolean')).to be_valid
      end

      it 'not valid with non proper amount of custom field per type' do
        2.times { publisher_custom_field_name(field_type: 'note').save }

        expect(publisher_custom_field_name(field_type: 'note')).not_to be_valid
      end
    end
  end

  private

  def valid_publisher_custom_field_name_params
    attributes_for :publisher_custom_field_name
  end

  def publisher_custom_field_name(opts={})
    PublisherCustomFieldName.new(valid_publisher_custom_field_name_params.merge(opts))
  end
end
