class Workflow::ParamsValuesFetcher
  def initialize(mapping_name, base_object_id, bo_name, mapped_cf_suffix = nil)
    @mapping_name = mapping_name
    @base_object_id = base_object_id
    @bo_name = bo_name
    @mapped_cf_suffix = mapped_cf_suffix
  end

  def fetch_values
    is_cf_mapping? ? get_custom_fields_mapping_values : get_db_mapping_values
  end

  private

  attr_reader :mapping_name, :bo_name, :base_object_id, :mapped_cf_suffix

  def join_statement_string
    mapping_hash[:join_statements].join(' ')
  end

  def base_query
    base_object_const.joins(join_statement_string).where(id: base_object_instance.id)
  end

  def base_object_const
    bo_name.titleize.constantize
  end

  def get_db_mapping_values
    return base_object_instance.public_send(mapping_hash[:target_field]) if mapping_hash[:is_base_mapping]
    return base_query.public_send(:pluck_to_hash, mapping_hash[:target_field]) if mapping_hash[:select_collection]
    base_query.pluck(mapping_hash[:target_field]).join.gsub("'"){"`"}
  end

  def get_custom_fields_mapping_values
    return base_query.pluck("#{ cf_name.field_type + cf_name.field_index.to_s}").first unless mapping_hash[:select_collection]
    base_query.public_send(:pluck_to_hash, "#{ cf_name.field_type + cf_name.field_index.to_s } as #{ mapped_cf_suffix }")
  end

  def cf_label
    mapped_cf_suffix.humanize.gsub(/\S+/, &:capitalize)
  end

  def cf_class_const
    mapping_hash[:cf_name_class_name].constantize
  end

  def is_cf_mapping?
    cf_mappings_array.include?(mapping_name)
  end

  def cf_mappings_array
    @_cf_mappings_array ||= CustomFieldsMappingsSelector.new(base_obj_singular_name_sym, base_object_instance.company_id)
                                .mappings_array
  end

  def base_object_db_table_name
    base_object_const.table_name
  end

  def base_object_instance
    @_base_object_instance ||= base_object_const.find(base_object_id)
  end

  def cf_name
    @_cf_name ||= cf_class_const.find_by('field_label ilike :label AND company_id = :company_id', label: "%#{cf_label}%",
                                         company_id: base_object_instance.company_id)
  end

  def mapping_hash
    @_mapping_hash ||= Workflow::MappingHashFinder.new(base_object_name_sym: bo_name.to_sym, mapping_name: mapping_name).find
  end

  def base_obj_singular_name_sym
    @_base_obj_singular_name_sym ||= base_object_db_table_name.singularize.to_sym
  end
end
