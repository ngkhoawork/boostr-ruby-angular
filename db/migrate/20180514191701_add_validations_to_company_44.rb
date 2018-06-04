class AddValidationsToCompany44 < ActiveRecord::Migration
  def up
    return unless company.present?
    company.validations.find_or_create_by(
      object: 'Account Custom Validation', 
      value_type: 'Boolean', 
      factor: 'Require USA State'
    ).criterion.update_attributes(
      value: true
    )
    company.validations.find_or_create_by(
      object: 'Account Custom Validation', 
      value_type: 'Boolean', 
      factor: 'Default Segment - Not Top 100'
    ).criterion.update_attributes(
      value: true
    )
  end

  def down
    company.validations.where(object: 'Account Custom Validation').destroy_all
  end

  def company
    @_company ||= Company.find_by(id: 44)
  end
end
