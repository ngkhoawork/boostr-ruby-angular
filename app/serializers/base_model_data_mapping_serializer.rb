class BaseModelDataMappingSerializer < ActiveModel::Serializer
  attributes :name,
             :model_fields_mapping,
             :model_attributes

  def name
    object.name.downcase
  end

  def model_fields_mapping
    model_attributes.map { |elem| "#{elem[:field_name]}" }
  end

  def model_attributes
    hash = {}
    current_company.deal_custom_field_names.map{|c| hash.merge!(c.field_type=> c.field_label)}
    return ActiveModel::ArraySerializer.new(current_company.deal_custom_field_names, each_serializer: CustomFieldDataTypesSerializer, obj_name: name, fields: hash).as_json if name.eql?(:deal_custom_field) && current_company.present?
    ActiveModel::ArraySerializer.new(allowed_columns, each_serializer: FieldDataTypesSerializer, obj_name: name, fields: hash ).as_json
  end

  def current_company
    options[:current_user].company
  end

  private

  def allowed_columns
    return [] unless defined? object::SAFE_COLUMNS
    object.columns.select do |column|
      object::SAFE_COLUMNS.include? column.name.to_sym
    end
  end
end