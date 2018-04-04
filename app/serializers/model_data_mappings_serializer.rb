class ModelDataMappingsSerializer < ActiveModel::Serializer
  attributes :name,
             :class_name,
             :related_base_class_name,
             :relation_type,
             :model_attributes

  def name
    object.name
  end

  def class_name
    object.class_name
  end

  def plural_name
    object.plural_name
  end

  def related_base_class
    object.active_record
  end

  def related_base_class_name
    related_base_class.to_s
  end

  def relation_type
    case object.class.name
      when 'ActiveRecord::Reflection::BelongsToReflection'
        'belongs_to'
      when 'ActiveRecord::Reflection::HasManyReflection'
        'has_many'
      when 'ActiveRecord::Reflection::ThroughReflection'
        'has_many_through'
      when 'ActiveRecord::Reflection::HasOneReflection'
        'has_one'
      else
        return
    end
  end

  def model_attributes
    hash = {}
    current_company.deal_custom_field_names.map{|c| hash.merge!(c.field_name=> c.field_label)}
    if object.klass.name.eql?("DealCustomField")
      ActiveModel::ArraySerializer.new(custom_model_attributes, each_serializer: FieldDataTypesSerializer, obj_name: object.name, fields: hash).as_json
    else
      ActiveModel::ArraySerializer.new(allowed_columns, each_serializer: FieldDataTypesSerializer, obj_name: object.name, fields: hash).as_json
    end
  end

  def relations
    DataModels::RelationsMappings.parsed_json[object.name.to_sym]
  end

  def current_company
    options[:current_user].company
  end

  def custom_model_attributes
    return [] unless defined? object.klass::SAFE_COLUMNS
    object.klass.columns.select do |column|
      current_company.deal_custom_field_names.map{|c|c.field_name}.include? column.name
    end
  end

  private

  def allowed_columns
    return [] unless defined? object.klass::SAFE_COLUMNS
    object.klass.columns.select do |column|
      object.klass::SAFE_COLUMNS.include? column.name.to_sym
    end
  end

end
