class Operative::XmlParserService
  attr_reader :response, :element

  def initialize(response, options)
    @response = response
    @element = options.fetch(:element)
  end

  def perform
    get_element_value
  end

  private

  def get_element_value
    parsed_xml.xpath("//#{element}").text
  end

  def parsed_xml
    Nokogiri::XML response.body
  end
end
