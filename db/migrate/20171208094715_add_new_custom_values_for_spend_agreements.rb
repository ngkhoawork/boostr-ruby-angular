class AddNewCustomValuesForSpendAgreements < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      company.fields.find_or_initialize_by(subject_type: 'SpendAgreement',
                                           name: 'Type',
                                           value_type: 'Option',
                                           locked: true)
      company.fields.find_or_initialize_by(subject_type: 'SpendAgreement',
                                           name: 'Status',
                                           value_type: 'Option',
                                           locked: true)
    end
  end
end
