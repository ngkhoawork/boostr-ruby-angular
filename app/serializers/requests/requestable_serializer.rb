class Requests::RequestableSerializer < ActiveModel::Serializer
  attributes(
    :id
  )

  def id
    if object.is_a?(ContentFee)
      object.product.name
    elsif object.is_a?(DisplayLineItem)
      object.line_number
    end
  end
end
