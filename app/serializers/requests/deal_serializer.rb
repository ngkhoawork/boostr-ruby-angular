class Requests::DealSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :io_id
  )

  def io_id
    object.io.try(:id)
  end
end
