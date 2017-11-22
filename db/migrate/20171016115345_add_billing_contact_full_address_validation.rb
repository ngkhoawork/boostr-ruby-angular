class AddBillingContactFullAddressValidation < ActiveRecord::Migration
  def change
    companies = Company.all
    companies.each do |company|
      company.validations.create(factor: 'Billing Contact Full Address', value_type: 'Boolean')
    end
  end
end
