class Api::Publishers::ExtendedFieldsSerializer < ActiveModel::Serializer
  attributes(
    :comscore,
    :type
  )

  has_one :publisher_custom_field

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end
end
