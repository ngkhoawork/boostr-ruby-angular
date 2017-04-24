class Api::ContactDetailSerializer < ActiveModel::Serializer
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
    :last_touched,
    :job_level,
    :won_deals,
    :lost_deals,
    :open_deals,
    :interactions
  )

  has_one :address
  has_one :contact_cf
  has_many :workplaces
  has_many :activities

  def primary_client_json
    if object.primary_client.present?
      object.primary_client.serializable_hash(only: [:id, :name, :client_type_id])
    else
      nil
    end
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

  def won_deals
    object.deals.won.count
  end

  def lost_deals
    object.deals.lost.count
  end

  def open_deals
    object.deals.open.count
  end

  def interactions
    object.activities.count
  end
end
