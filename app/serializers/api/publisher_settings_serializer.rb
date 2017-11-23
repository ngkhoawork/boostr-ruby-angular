class Api::PublisherSettingsSerializer
  def initialize(company)
    @company = company
  end

  def as_json(*_args)
    {
      publisher_types: publisher_types,
      publisher_stages: publisher_stages,
      comscore: [true, false]
    }
  end

  private

  def publisher_types
    publisher_type_field&.options.map do |option|
      option.serializable_hash(only: [:id, :name, :probability])
    end
  end

  def publisher_stages
    @company.publisher_stages.map do |publisher_stage|
      publisher_stage.serializable_hash(only: :id, methods: :name)
    end
  end

  def publisher_type_field
    @company.fields.where(subject_type: 'Publisher', name: 'Publisher Type').first
  end
end
