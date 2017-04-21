class ContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :position,
    :client_id,
    :created_by,
    :updated_by,
    :created_at,
    :updated_at,
    :company_id,
    :activity_updated_at,
    :note,
    :formatted_name,
    :primary_client_json,
    :last_touched,
    :job_level
  )

  has_one :address

  def primary_client_json
    object.primary_client.serializable_hash(only: [:id, :name, :client_type_id]) rescue nil
  end

  def formatted_name
    name
  end

  def last_touched
    object.latest_happened_activity.first.try(:happened_at)
  end

  def job_level
    if object.values.present? && @options[:contact_options].present?
      field_id = @options[:contact_options].first.field_id
      value = object.values.find do |el|
        el.field_id == field_id
      end
      option = @options[:contact_options].find do |el|
        el.id == value.option_id
      end
    end

    if option
      option.name
    else
      nil
    end
  end
end
