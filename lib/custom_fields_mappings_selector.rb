class CustomFieldsMappingsSelector
  attr_reader :mappings_array, :company_id, :base_object_name

  def initialize(base_object_name, company_id)
    @base_object_name = base_object_name
    @company_id = company_id
    @mappings_array = get_mappings_array
  end

  private

  def get_mappings_array
    build_mappings.flatten
  end

  def build_mappings
    mappings_hash.each_with_object([]) do |mapping, arr|
      cf_names = company.public_send(mapping[:cf_table_name])
      arr.push( cf_names.map {|cf| "#{ mapping[:ui_prefix] }.#{ cf.underscored_field_label }" } )
    end
  end

  def mappings_hash
    @_mappings_hash ||= DataModels::CfDataMappings.get_mappings(base_object_name)
  end

  def company
    @_company ||= Company.find(@company_id)
  end
end
