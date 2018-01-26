class FlatPublisherCustomFieldSerializer < ActiveModel::Serializer
  def attributes
    publisher_custom_field_names.map(&:field_label).inject({}) do |acc, attribute_name|
      acc[attribute_name] = attribute_value(attribute_name)
      acc
    end
  end

  private

  def publisher_custom_field_names
    @publisher_custom_field_names ||= object.company.publisher_custom_field_names.to_a
  end

  def attribute_value(attribute_name)
    field_name = publisher_custom_field_name_by_field_label(attribute_name)

    object.send("#{field_name.field_type}#{field_name.field_index}")
  end

  def publisher_custom_field_name_by_field_label(field_label)
    publisher_custom_field_names.detect do |publisher_custom_field_name|
      publisher_custom_field_name.field_label == field_label
    end
  end
end
