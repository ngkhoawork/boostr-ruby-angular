class Workflow::ParamsHashBuilder
  def initialize(parsed_params, base_object_id, bo_name)
    @parsed_params = parsed_params
    @bo_name = bo_name
    @base_object_id = base_object_id
  end

  def build
    parsed_params.each_with_object({}) do |param, hsh|
      mapped_prefix, mapped_suffix = param.split('.')

      mapping_hash = Workflow::MappingHashFinder.new(base_object_name_sym: bo_name.to_sym,
                                                     mapping_name: param).find

      values = format_data(Workflow::ParamsValuesFetcher.new(param, base_object_id, bo_name, mapped_suffix).fetch_values)
      next unless mapping_hash
      if mapping_hash[:select_collection]
        next hsh[mapped_prefix].concat(values) if hsh[mapped_prefix]
        next hsh[mapped_prefix] = values
      else
        nested_hash[mapped_prefix][mapped_suffix] = values
        hsh.merge!(nested_hash)
      end
    end
  end

  def format_data(data)
    return format_date(data) if data.is_a?(String) && data.to_s.include?("UTC")
    return format_date(data) if data.is_a?(Time)
    return format_date(data) if data.is_date?

    return rounded(data.to_f) + " " if data.is_a?(BigDecimal)
    return format_arr(data) if data.is_a?(Array)
    return format_arr(data) if data.is_a?(Hash)
    return number_with_delimiter(data.to_f) if is_number?(data)
    data
  end

  def is_number?(data)
    !!Float(data)
  rescue TypeError, ArgumentError
    false
  end

  def format_date(origin_date)
    origin_date.to_date.to_s
  end

  def format_arr(data)
    data.map{|c| detect_format(c)}
  end

  def detect_format(val)
    return format_date(val) if val.is_a?(Time)
    return format_date(val) if val.is_date?
    return (val.to_f) if val.is_a?(BigDecimal)
    return handle_hash(val) if val.is_a?(Hash)
    val
  end

  def rounded(val)
    number_with_delimiter(val)
  end

  def handle_hash(val)
    val.each do |k,v|
      val[k] = number_with_delimiter(val[k]) if val[k].is_a?(BigDecimal)
      val[k] = format_date(val[k]) if val[k].is_a?(Time) || val[k].to_s.include?("UTC")
    end
  end

  def number_with_delimiter(number, delimiter=",")
    number.round.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
  end

  private

  attr_reader :parsed_params, :bo_name, :base_object_id

  def nested_hash
    @_nested_hash ||= Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
  end
end
