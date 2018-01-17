class AddRequireWonReasonValidationToCompanies < ActiveRecord::Migration
  def up
    Company.all.each do |company|
      company.validations.create(factor: 'Require Won Reason', value_type: 'Boolean')
    end
  end

  def down
    Validation.destroy_all(factor: 'Require Won Reason', value_type: 'Boolean')
  end
end
