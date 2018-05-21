class InitSpendAgreementMemberFields < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Member Role', value_type: 'Option', locked: true)
    end
  end
end
