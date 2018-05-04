class Egnyte::Endpoints::Response
  STATUS_CODES = {
    success: %w(200 201 204),
    bad_request: %w(400),
    forbidden: %w(403),
    not_found: %w(404)
  }.freeze

  delegate :code, to: :@response

  def initialize(response)
    raise ArgumentError unless response
    @response = response
  end

  def body
    return @body if @body

    @body = JSON.parse(@response.body, symbolize_names: true) if @response.body.present?
  rescue JSON::ParserError
    @body = @response.body
  end

  def success?
    STATUS_CODES[:success].include?(code)
  end

  def bad_request?
    STATUS_CODES[:bad_request].include?(code)
  end

  def forbidden?
    STATUS_CODES[:forbidden].include?(code)
  end

  def not_found?
    STATUS_CODES[:not_found].include?(code)
  end

  def folder_already_exists?
    forbidden? && (body[:errorMessage] =~ /folder already exists/i)
  end
end
