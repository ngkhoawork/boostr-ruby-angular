class AddDefaultContractStatusOptions < ActiveRecord::Migration
  def change
    setup_default_status_options
    drop_default_member_role_options
    drop_default_contact_role_options
  end

  private

  def setup_default_status_options
    status_fields = Field.joins(:company).where(subject_type: 'Contract', name: 'Status').distinct

    status_fields.each do |field|
      option_names.each do |option_name|
        option = Option.find_or_initialize_by(field: field, name: option_name)
        option.attributes = { company: field.company, locked: true }
        option.save(validate: false)
      end
    end
  end

  def drop_default_member_role_options
    member_role_field_ids = Field.joins(:company).where(subject_type: 'Contract', name: 'Member Role').pluck(:id).uniq

    Option.where(field_id: member_role_field_ids, name: option_names).update_all(locked: false)
  end

  def drop_default_contact_role_options
    contact_role_field_ids = Field.joins(:company).where(subject_type: 'Contract', name: 'Contact Role').pluck(:id).uniq

    Option.where(field_id: contact_role_field_ids, name: option_names).update_all(locked: false)
  end

  def option_names
    %w(Active Expired)
  end
end
