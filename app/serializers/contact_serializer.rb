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
    :primary_client_type,
    :client,
    :non_primary_client_contacts,
    :last_touched,
    :job_level
  )

  has_one :address
  has_one :contact_cf

  def primary_client_json
    object.primary_client.serializable_hash(only: [:id, :name, :client_type_id]) rescue nil
  end

  def client
    object.client.serializable_hash(only: [:id, :name, :client_type_id]) rescue nil
  end

  def primary_client_type
    return '' unless object.primary_client.present?
    if object.primary_client.client_type_id == @options[:advertiser]
      'Advertiser'
    elsif object.primary_client.client_type_id == @options[:agency]
      'Agency'
    else
      ''
    end
  end

  def formatted_name
    name
  end

  def last_touched
    if object.latest_happened_activity.any?
      object.latest_happened_activity.first.happened_at
    end
  end

  def job_level
    if object.values.present? && @options[:contact_options].present?
      field_id = @options[:contact_options].first.field_id
      value = object.values.find do |el|
        el.field_id == field_id
      end
      option = @options[:contact_options].find do |el|
        el.id == value.option_id
      end if value
    end

    if option
      option.name
    else
      nil
    end
  end
end
