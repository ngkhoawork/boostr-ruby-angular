class Api::V2::ActivityListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :activity_type_id,
    :activity_type_name,
    :happened_at,
    :timed,
    :comment,
    :contacts,
    :creator,
    :client,
    :agency,
    :deal,
    :publisher
  )

  def contacts
    object.contacts_info
  end

  def creator
    object.creator.serializable_hash(only: [:id], methods: :name) rescue nil
  end

  def client
    object.client.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def deal
    object.deal.serializable_hash(only: [:id, :name]) rescue nil
  end

  def publisher
    object.publisher&.serializable_hash(only: [:id, :name])
  end

  def comment
    if object.activity_type_name == 'Email'
      ''
    else
      object.comment
    end
  end
end
