class Workflow::MessageNormalizer
  def initialize(original_message, parsed_message_params, bo_name)
    @original_message = original_message
    @parsed_message_params = parsed_message_params
    @bo_name = bo_name
  end

  def normalize
    replace_iterated_params
    original_message
  end

  private

  attr_reader :original_message, :parsed_message_params, :bo_name

  def replace_iterated_params
    parsed_message_params.each do |plural_reflection|
      mapped_prefix, mapped_suffix  = plural_reflection.split('.')
      mapping_hash = Workflow::MappingHashFinder.new(base_object_name_sym: bo_name.to_sym,
                                                     mapping_name: plural_reflection).find
      next unless mapping_hash
      next unless mapping_hash[:select_collection]
      original_message.gsub!(replace_regex(plural_reflection), iterative_mustache_string(mapped_prefix, mapped_suffix))
    end
  end

  def iterative_mustache_string(object, param)
    "\n{{##{object}}}{{#{param}}} {{/#{object}}}"
  end

  def replace_regex(pluralized_mapping)
    Regexp.new("{{#{pluralized_mapping}}}")
  end
end
