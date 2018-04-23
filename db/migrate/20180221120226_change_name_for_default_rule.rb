class ChangeNameForDefaultRule < ActiveRecord::Migration
  def change
    AssignmentRule.where(name: 'Default', default: true).delete_all

    Company.all.find_each do |company|
      users = company.users
      user = users.blank? ? users : [users.first]

      AssignmentRule.create(company_id: company.id, name: 'No Match', default: true, users: user, position: 100_000)
    end
  end
end
