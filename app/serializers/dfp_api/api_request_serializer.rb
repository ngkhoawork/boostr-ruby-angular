class DfpApi::ApiRequestSerializer < ActiveModel::Serializer
  attributes :body, :endpoint, :api_method

  def body
    object.http.body
  end

  def api_method
    object.soap.input[1].to_s
  end

  def endpoint
    object.soap.endpoint
  end
end