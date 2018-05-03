class Api::Contracts::RestrictedSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :name,
    :restricted,
    :type
  )

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end
end
