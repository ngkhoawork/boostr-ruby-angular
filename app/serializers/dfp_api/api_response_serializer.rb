class DfpApi::ApiResponseSerializer < ActiveModel::Serializer
  attributes :status, :body

  def status
    object.code
  end

  def body
    object.raw_body
  end

end