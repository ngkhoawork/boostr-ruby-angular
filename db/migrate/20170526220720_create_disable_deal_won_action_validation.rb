class CreateDisableDealWonActionValidation < ActiveRecord::Migration
  def change
    create_disable_deal_won_action_validation
  end

  def create_disable_deal_won_action_validation
    companies = Company.all
    companies.each do |company|
      company.validations.create({
        factor: 'Disable Deal Won',
        value_type: 'Boolean'
      })
    end
  end
end
