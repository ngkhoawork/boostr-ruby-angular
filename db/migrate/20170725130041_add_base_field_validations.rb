class AddBaseFieldValidations < ActiveRecord::Migration
  def change
    add_column :validations, :object, :string, default: ''

    new_validations = [
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_category_id' },
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_subcategory_id' },
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_region_id' },
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_segment_id' },
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'phone' },
      { object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'website' },
      { object: 'Agency Base Field',     value_type: 'Boolean', factor: 'client_region_id' },
      { object: 'Agency Base Field',     value_type: 'Boolean', factor: 'client_segment_id' },
      { object: 'Agency Base Field',     value_type: 'Boolean', factor: 'phone' },
      { object: 'Agency Base Field',     value_type: 'Boolean', factor: 'website' }
    ]

    Company.find_each do |company|
      new_validations.each do |validation_data|
        company.validations.find_or_create_by(validation_data)
      end
    end
  end
end
