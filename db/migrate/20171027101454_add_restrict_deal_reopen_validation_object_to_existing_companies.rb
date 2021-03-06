class AddRestrictDealReopenValidationObjectToExistingCompanies < ActiveRecord::Migration
  def change
    company_ids_with_validation =
      Company
        .joins(:validations)
        .where(validations: { factor: 'Restrict Deal Reopen', value_type: 'Boolean' }).pluck(:id)

    Company.where.not(id: company_ids_with_validation).find_each do |company|
      company.validations.create(factor: 'Restrict Deal Reopen', value_type: 'Boolean')
    end
  end
end
