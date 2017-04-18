class Api::V1::ActivityListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :activity_type_name,
    :happened_at,
    :comment,
    :contacts,
    :creator,
    :client,
    :deal
  )

  def contacts
    object.contacts.serializable_hash(only: [:id, :name]) rescue nil
  end

  def creator
    object.creator.serializable_hash(only: [:id, :first_name, :last_name]) rescue nil
  end

  def client
    object.client.serializable_hash(only: [:id, :name]) rescue nil
  end

  def deal
    object.deal.serializable_hash(only: [:id, :name]) rescue nil
  end

  def comment
    if object.activity_type_name == 'Email'
      ''
    else
      object.comment
    end
  end
end
