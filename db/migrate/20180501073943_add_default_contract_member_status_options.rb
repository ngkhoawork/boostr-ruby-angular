class AddDefaultContractMemberStatusOptions < ActiveRecord::Migration
  def change
    member_role_fields = Field.joins(:company).where(subject_type: 'Contract', name: 'Member Role').distinct

    member_role_fields.each do |field|
      option_names.each do |option_name|
        option = Option.find_or_initialize_by(field: field, name: option_name)
        option.attributes = { company: field.company, locked: true }
        option.save(validate: false)
      end
    end
  end

  private

  def option_names
    %w(Active Expired)
  end
end
