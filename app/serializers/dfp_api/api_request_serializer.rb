class DfpApi::ApiRequestSerializer < ActiveModel::Serializer
  attributes :body

  def body
    object.http.body
  end
end