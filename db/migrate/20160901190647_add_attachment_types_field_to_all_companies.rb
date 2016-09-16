class AddAttachmentTypesFieldToAllCompanies < ActiveRecord::Migration
  def change
    companies = Company.all
    companies.each do |company|
      company.fields.find_or_initialize_by(subject_type: 'Multiple', name: 'Attachment Type', value_type: 'Option', locked: true)
      company.save
    end
  end
end
