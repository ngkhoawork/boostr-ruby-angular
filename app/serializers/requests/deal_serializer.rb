class Requests::DealSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :io_id,
    :io_name
  )

  def io_id
    object.io.try(:id)
  end

  def io_name
    object.io.try(:name)
  end
end
