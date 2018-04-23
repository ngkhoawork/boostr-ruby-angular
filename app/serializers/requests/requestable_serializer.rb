class Requests::RequestableSerializer < ActiveModel::Serializer
  attributes(
    :id, :name
  )

  def name
    if object.is_a?(ContentFee)
      "#{object.product.full_name}"
    elsif object.is_a?(DisplayLineItem)
      "Line Number #{object.line_number}"
    else
      "IO #{object.id}"
    end
  end
end
