class Workflow::MappingHashFinder
  def initialize(options)
    @options = options
  end

  def find
    arr = mapping_name.split('.')
    mapped_prefix = arr[0]
    find_mapping_attributes(mapping_name) || find_cf_mapping_attributes(mapped_prefix)
  end

  private

  attr_reader :options

  def bo_name
    options[:base_object_name_sym]
  end

  def mapping_name
    options[:mapping_name]
  end

  def find_cf_mapping_attributes(ui_prefix)
    found_params = cf_data_mappings.select { |mapping| mapping[:ui_prefix] == ui_prefix }
    found_params&.first
  end

  def find_mapping_attributes(mapping_name)
    found_params = db_data_mappings.select { |mapping| mapping[:name] == mapping_name }
    found_params&.first
  end

  def db_data_mappings
    DataModels::DbDataMappings.get_mappings(bo_name)
  end

  def cf_data_mappings
    DataModels::CfDataMappings.get_mappings(bo_name)
  end
end
