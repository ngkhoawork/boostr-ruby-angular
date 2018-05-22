class CustomFields::Serializer < ActiveModel::Serializer
  def attributes
    object.attributes.select { |key, _value| allowed_attr_names.include?(key) }
  end

  private

  def allowed_attr_names
    @allowed_attr_names ||= object.allowed_attr_names
  end
end
