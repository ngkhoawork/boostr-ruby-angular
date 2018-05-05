class AddRejectionExplanationValidationForLeads < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      company.validations.find_or_create_by(object: 'Lead', value_type: 'Boolean', factor: 'Require Rejection Explanation')
    end
  end
end
