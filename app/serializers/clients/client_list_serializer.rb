class Clients::ClientListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :formatted_name,
    :type,
    :category,
    :client_members,
    :city,
    :latest_advertiser_activity,
    :latest_agency_activity
  )

  def type
    if object.client_type_id == @options[:advertiser]
      'Advertiser'
    elsif object.client_type_id == @options[:agency]
      'Agency'
    else
      ''
    end
  end

  def category
    @options[:categories].find{ |el| el.id == object.client_category_id }&.name
  end

  def client_members
    object.client_member_info.map { |el| el.serializable_hash(only: [:id, :share, :first_name, :last_name]) }
  end

  def city
    object.address.city
  end

  def latest_advertiser_activity
    object.latest_advertiser_activity&.happened_at
  end

  def latest_agency_activity
    object.latest_agency_activity&.happened_at
  end

  def formatted_name
    f_name = name

    f_name += ", #{object.address.city}" if object.address&.city.present?
    f_name += ", #{object.address.state}" if object.address&.state.present?

    f_name
  end
end
