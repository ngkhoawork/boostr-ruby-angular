class PublisherCustomFieldSerializer < ActiveModel::Serializer
  def attributes
    publisher_custom_field_names.map do |field_name|
      [field_name.field_label, field_name.field_type]
    end.inject([]) do |acc, (field_label, field_type)|
      acc << {
        field_label: field_label,
        field_type: field_type,
        field_value: fetch_field_value(field_label)
      }
    end
  end

  private

  def publisher_custom_field_names
    @publisher_custom_field_names ||= object.company.publisher_custom_field_names.to_a
  end

  def fetch_field_value(field_label)
    field_name = publisher_custom_field_name_by_field_label(field_label)

    object.send("#{field_name.field_type}#{field_name.field_index}")
  end

  def publisher_custom_field_name_by_field_label(field_label)
    publisher_custom_field_names.detect do |publisher_custom_field_name|
      publisher_custom_field_name.field_label == field_label
    end
  end
end
