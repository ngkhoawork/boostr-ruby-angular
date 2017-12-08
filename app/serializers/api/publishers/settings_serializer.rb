class Api::Publishers::SettingsSerializer
  def initialize(company)
    @company = company
  end

  def as_json(*_args)
    {
      publisher_types: publisher_types,
      publisher_stages: publisher_stages,
      comscore: [true, false],
      custom_field_names: custom_field_names,
      renewal_term_fields: renewal_term_fields
    }
  end

  private

  def publisher_types
    publisher_type_field&.options.map do |option|
      option.serializable_hash(only: [:id, :name, :probability])
    end
  end

  def publisher_stages
    @company.publisher_stages.active.order_by_open_and_probability.map do |publisher_stage|
      publisher_stage.serializable_hash(only: :id, methods: [:name, :probability])
    end
  end

  def custom_field_names
    @company
      .publisher_custom_field_names
      .includes(:publisher_custom_field_options)
      .inject([]) do |acc, field_name|
        acc << {
          id: field_name.id,
          field_label: field_name.field_label,
          field_options: field_name.publisher_custom_field_options.map(&:value)
        }
      end
  end

  def publisher_type_field
    @company.fields.find_by(subject_type: 'Publisher', name: 'Publisher Type')
  end

  def renewal_term_fields
    renewal_term_field&.options.map do |option|
      option.serializable_hash(only: [:id, :name, :probability])
    end
  end

  def renewal_term_field
    @company.fields.find_by(subject_type: 'Publisher', name: 'Renewal Terms')
  end
end
