class CreateAccountManagerDealValidation < ActiveRecord::Migration
  def change
    create_account_manager_validation
  end

  def create_account_manager_validation
    companies = Company.all
    companies.each do |company|
      company.validations.create({
        factor: 'Account Manager',
        value_type: 'Number'
      })
    end
  end
end
