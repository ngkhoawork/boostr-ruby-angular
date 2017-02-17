class AddRoleToDealContact < ActiveRecord::Migration
  def change
    add_column :deal_contacts, :role, :string
    create_contact_role_field
  end

  def create_contact_role_field
    companies = Company.all
    companies.each do |company|
      field = company.fields.find_or_initialize_by(subject_type: 'Deal', name: 'Contact Role', value_type: 'Option', locked: true)
      field.options.find_or_initialize_by(name: 'Billing', company: company, locked: true)
      field.save
    end
  end
end
