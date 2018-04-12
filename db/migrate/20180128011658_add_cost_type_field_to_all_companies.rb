class AddCostTypeFieldToAllCompanies < ActiveRecord::Migration
  def up
    Company.all.each do |company|
      company.fields.find_or_create_by(subject_type: 'Cost', name: 'Cost Type', value_type: 'Option', locked: true)
    end
  end

  def down
    Field.destroy_all(subject_type: 'Cost', name: 'Cost Type', value_type: 'Option')
  end
end
