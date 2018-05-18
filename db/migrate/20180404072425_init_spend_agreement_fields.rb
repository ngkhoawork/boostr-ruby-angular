class InitSpendAgreementFields < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Type', value_type: 'Option', locked: true)
      company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Status', value_type: 'Option', locked: true)
    end
  end
end
