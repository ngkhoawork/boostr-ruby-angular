class CustomFields::Serializer < ActiveModel::Serializer
  attributes *CustomField.attribute_names.map(&:to_sym)

  def attributes(*params)
    super(*params).select { |key, value| value.present? }
  end
end
