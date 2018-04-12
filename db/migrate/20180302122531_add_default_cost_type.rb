class AddDefaultCostType < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      cost_type = company.fields.find_or_create_by(subject_type: 'Cost', name: 'Cost Type', value_type: 'Option', locked: true)
      cost_type.options.find_or_create_by(name: 'General', company: company, locked: true)
    end
  end
end
