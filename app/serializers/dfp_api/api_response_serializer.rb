class DfpApi::ApiResponseSerializer < ActiveModel::Serializer
  attributes :status, :body, :is_error, :api_method_name

  def status
    object.code
  end

  def body
    object.raw_body
  end

  def is_error
    status == 500
  end

  def api_method_name
    parsed_resp.xpath('name(/Envelope/Body/*[1])')
  end

  def get_rval
    parsed_resp.xpath('/Envelope/Body').text
  end

  def parsed_resp
    doc = Nokogiri::XML object.raw_body
    doc.remove_namespaces!
    doc
  end

end