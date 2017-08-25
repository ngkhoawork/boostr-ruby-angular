class AddBaseFieldValidationsToDeals < ActiveRecord::Migration
  def change
    new_validations = [
      { object: 'Deal Base Field', value_type: 'Boolean', factor: 'deal_type_value' },
      { object: 'Deal Base Field', value_type: 'Boolean', factor: 'deal_source_value' },
      { object: 'Deal Base Field', value_type: 'Boolean', factor: 'agency' },
      { object: 'Deal Base Field', value_type: 'Boolean', factor: 'next_steps' }
    ]

    Company.find_each do |company|
      new_validations.each do |validation_data|
        company.validations.find_or_create_by(validation_data)
      end
    end
  end
end
