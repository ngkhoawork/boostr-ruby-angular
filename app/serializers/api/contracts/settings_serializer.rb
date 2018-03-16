class Api::Contracts::SettingsSerializer
  def initialize(company, *_args)
    @company = company
  end

  def as_json(*_args)
    {
      type_options: options_for(type_field),
      status_options: options_for(status_field),
      member_role_options: options_for(member_role_field),
      contact_role_options: options_for(contact_role_field),
      special_term_name_options: options_for(special_term_name_field),
      special_term_type_options: options_for(special_term_type_field)
    }
  end

  private

  def type_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Type')
  end

  def status_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Status')
  end

  def member_role_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Member Role')
  end

  def contact_role_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Contact Role')
  end

  def special_term_name_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Special Term Name')
  end

  def special_term_type_field
    @company.fields.find_by(subject_type: 'Contract', name: 'Special Term Type')
  end

  def options_for(field)
    return [] unless field

    field.options.map { |option| option.serializable_hash(only: [:id, :field_id, :name, :position, :option_id]) }
  end
end
