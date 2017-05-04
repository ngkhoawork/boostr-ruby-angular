class Api::V2::ClientListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :contacts_count,
    :deals_count,
    :type_name
  )

  def type_name
    if object.client_type_id == @options[:advertiser]
      'Advertiser'
    elsif object.client_type_id == @options[:agency]
      'Agency'
    else
      ''
    end
  end
end
