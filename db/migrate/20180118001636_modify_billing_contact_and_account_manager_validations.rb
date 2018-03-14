class ModifyBillingContactAndAccountManagerValidations < ActiveRecord::Migration
  def up
    Validation.where(factor: ['Billing Contact', 'Account Manager']).each do |validation|
      company = validation.company
      stage = company.default_sales_process&.stages&.where(probability: validation.criterion.value)&.first
      if stage.present?
        company.validations.create!(
          object: validation.factor, 
          factor: stage.sales_process&.id, 
          value_type: 'Object'
        ).criterion.update_attributes(
          value_object_id: stage.id,
          value_object_type: 'Stage'
        )
        validation.destroy!
      end
    end
  end

  def down
    Validation.where(object: ['Billing Contact', 'Account Manager'], value_type: 'Object').each do |validation|
      if validation.criterion.value.present?
        company = validation.company
        company.validations.create!(
          factor: validation.object,
          value_type: 'Number'
        ).criterion.update_attributes(
          value: validation.criterion.value.probability
        )
      end
      validation.destroy!
    end
  end
end
