class FixBrokenClientValues < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      field = Field.find_by(company_id: company.id, subject_type: 'Client', name: 'Client Type')
      oids = field.options.ids
      Value.where(company_id: company.id, option_id: oids).where.not(field_id: field.id).update_all(field_id: field.id)
    end
  end
end
