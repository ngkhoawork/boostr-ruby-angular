class Csv::PublisherAllFieldsReportDecorator
  DELEGATE_TO_PUBLISHER_ATTRIBUTES =
    %i(id name comscore website estimated_monthly_impressions actual_monthly_impressions).freeze

  def initialize(record)
    @record = record
  end

  DELEGATE_TO_PUBLISHER_ATTRIBUTES.each do |method_name|
    define_method(method_name) do
      @record.send(method_name)
    end
  end

  def type
    @record.type&.name
  end

  def publisher_stage
    @record.publisher_stage&.name
  end

  def client
    @record.client&.name
  end

  def created_at
    @record.created_at.to_date
  end

  def custom_fields
    return unless @record.publisher_custom_field

    FlatPublisherCustomFieldSerializer.new(@record.publisher_custom_field).attributes
  end
end
