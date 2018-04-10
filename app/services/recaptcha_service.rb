class RecaptchaService
  API_URL = 'https://www.google.com/'
  ENDPOINT = 'recaptcha/api/siteverify'
  BUZZFEED_RECAPTCHA_SECRET_KEY = '6LeDkEIUAAAAAGsGv6xIaJifiAOWVoMXop0FJmGK'

  def initialize(company_id, response)
    @company_id = company_id.to_i
    @params = { response: response, secret: determine_secret_key }
  end

  def succeed?
    response_body['success']
  end

  private

  attr_reader :params, :company_id

  def connection
    Faraday.new(url: API_URL) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end

  def request
    connection.post(ENDPOINT, params)
  end

  def response_body
    JSON.parse(request.body)
  end

  def determine_secret_key
    case company_id
    when 44
      BUZZFEED_RECAPTCHA_SECRET_KEY
    end
  end
end
