class Workflow::AttachmentHashBuilder
  def initialize(workflowable_object, options = {})
    @workflowable_object = workflowable_object
    @options = options
  end

  def build
    return attachment_hash.merge!(object_link_hash) unless options[:destroyed]
    attachment_hash
  end

  private

  attr_reader :workflowable_object, :options

  def attachment_hash
    {
        color: '#FD7222',
        text: attachment_text
    }
  end

  def object_link_hash
    {
        title: "Go to #{workflowable_obj_name} in Boostr",
        title_link: fallback_link
    }
  end

  def attachment_text
    attachment_mappings.each_with_object('') do |mapping, text|
      value = fetch_values_for_mapping(mapping['name'])
      formatted_value = formatted_string(value)
      next if formatted_value.blank?
      text << "*#{mapping['label_name']}*: #{formatted_value}\n"
    end
  end

  def formatted_string(data)
    return format_date(data) if data.is_date?
    return format_arr(data) if data.is_a?(Array)
    return round(data.to_f) if data.is_a?(BigDecimal)
    return data.to_date.to_s if data.is_a?(ActiveSupport::TimeWithZone)
    return format_number(data) if is_number?(data)
    data
  end

  def is_number?(data)
    !!Float(data)
  rescue TypeError, ArgumentError
    false
  end

  def format_number(data)
    '%.2f' % data
  end

  def format_arr(data)
    return if data.blank?
    data.map{|c| detect_format(c.symbolize_keys.values)}.join('; ')
  end

  def detect_format(val)
    return (val.to_f) if val.is_a?(BigDecimal)
    val
  end

  def round(val)
    number_with_delimiter(val.round)
  end

  def number_with_delimiter(number, delimiter=",")
    number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
  end

  def workflowable_obj_name
    workflowable_object.class.name.downcase
  end

  def format_date(origin_date)
    origin_date.strftime('%b %d, %Y')
  end

  def attachment_mappings
    options.fetch(:attachment_mappings)
  end

  def fallback_link
    "#{SLACK_CONNECT.protocol}://#{SLACK_CONNECT.base_uri}/deals/#{workflowable_object.id}"
  end

  def fetch_values_for_mapping(mapping_name)
    mapped_suffix = mapping_name.split('.').last
    Workflow::ParamsValuesFetcher.new(mapping_name,
                                      workflowable_object.id,
                                      workflowable_obj_name,
                                      mapped_suffix).fetch_values
  end
end
