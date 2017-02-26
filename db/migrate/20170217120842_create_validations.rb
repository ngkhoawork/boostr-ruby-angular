class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations do |t|
      t.belongs_to :company, index: true
      t.string :factor
      t.string :value_type

      t.timestamps
    end

    add_column :values, :value_boolean, :boolean

    create_contact_validation
  end

  def create_contact_validation
    companies = Company.all
    companies.each do |company|
      company.validations.create({
        factor: 'Billing Contact',
        value_type: 'Number'
      })
    end
  end
end
