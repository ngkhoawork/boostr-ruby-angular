class FieldDataTypesSerializer < ActiveModel::Serializer
  attributes :field_name, :field_label, :data_type, :sql_type

  def field_name
    object.name
  end

  def field_label
    case options[:obj_name]
    when :deal_custom_field
      options[:fields][object.name]
    when :account_cf
      options[:fields][object.name]
    else
      DataModels::LabelMappings.parsed_json[object.name.to_sym]
    end
  end



  def data_type
    object.type
  end

  def sql_type
    object.sql_type
  end
end
