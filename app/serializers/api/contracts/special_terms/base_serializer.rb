class Api::Contracts::SpecialTerms::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :type
  )

  private

  def name
    object.name&.serializable_hash(only: [:id, :name])
  end

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end
end
