class CustomFieldDataTypesSerializer < ActiveModel::Serializer
  attributes :field_name, :field_label, :data_type, :sql_type

  def field_name
    object.name
  end

  def field_label
    object.field_label
  end

  def data_type
    "custom"
  end

  def sql_type
    object.field_type
  end
end
