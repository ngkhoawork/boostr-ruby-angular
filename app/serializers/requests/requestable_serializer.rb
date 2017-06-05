class Requests::RequestableSerializer < ActiveModel::Serializer
  attributes(
    :id
  )

  def id
    if object.is_a?(ContentFee)
      object.product.name
    else
      object.id
    end
  end
end
