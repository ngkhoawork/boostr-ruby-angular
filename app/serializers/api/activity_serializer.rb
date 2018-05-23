class Api::ActivitySerializer < ActiveModel::Serializer
  attributes(
    :id,
    :happened_at,
    :comment,
    :activity_type,
    :client,
    :contacts,
    :deal,
    :publisher
  )

  has_one :creator, serializer: Api::Publishers::UserSerializer
  has_one :custom_field, serializer: CustomFields::Serializer

  private

  def activity_type
    object.activity_type&.serializable_hash(only: [:id, :name, :action, :css_class, :icon])
  end

  def client
    object.client&.serializable_hash(only: [:id, :name])
  end

  def contacts
    object.contacts.map { |contact| contact.serializable_hash(only: [:id, :name]) }
  end

  def deal
    object.deal&.serializable_hash(only: [:id, :name])
  end

  def publisher
    object.publisher&.serializable_hash(only: [:id, :name])
  end
end
