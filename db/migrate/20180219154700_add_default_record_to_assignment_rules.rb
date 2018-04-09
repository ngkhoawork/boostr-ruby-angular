class AddDefaultRecordToAssignmentRules < ActiveRecord::Migration
  def change
    Company.all.find_each do |company|
      AssignmentRule.create(company_id: company.id, name: 'Default', default: true)
    end
  end
end
