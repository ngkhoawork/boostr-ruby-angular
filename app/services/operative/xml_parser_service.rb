class Operative::XmlParserService
  def initialize(response, options)
    @response = response
    @element = options.fetch(:element)
    @deal = options.fetch(:deal, false)
  end

  def perform
    get_element_value
  end

  private

  attr_reader :response, :element, :deal

  def get_element_value
    deal ? get_deal_id : parsed_xml.xpath("//#{element}").text
  end

  def get_deal_id
    parsed_xml.remove_namespaces!.xpath("/Collection/salesOrder/#{element}").text
  end

  def parsed_xml
    puts response
    Nokogiri::XML response.body
  end
end
