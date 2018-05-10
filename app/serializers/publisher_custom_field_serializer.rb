class PublisherCustomFieldSerializer < ActiveModel::Serializer
  def attributes
    publisher_custom_field_names.inject([]) do |acc, custom_field_name|
      acc << {
        field_label: custom_field_name.field_label,
        field_type: custom_field_name.field_type,
        field_value: fetch_field_value(custom_field_name),
        attr_name: custom_field_name.field_name,
        field_index: custom_field_name.field_index
      }
    end
  end

  private

  def publisher_custom_field_names
    @publisher_custom_field_names ||= object.company.publisher_custom_field_names.to_a
  end

  def fetch_field_value(custom_field_name)
    object.send(custom_field_name.field_name)
  end
end
