class Egnyte::Endpoints::Oauth < Egnyte::Endpoints::Net
  PREDEFINED_REQUEST_PARAMS = {
    grant_type: 'authorization_code'
  }.freeze

  REQUIRED_OPTIONS = %i(domain redirect_uri code).freeze

  def initialize(options)
    @options = options.deep_symbolize_keys

    REQUIRED_OPTIONS.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  private

  def request_method
    :post
  end

  def host
    @options[:domain].start_with?('http') ? @options[:domain] : "https://#{@options[:domain]}"
  end

  def path
    'puboauth/token'
  end

  def request_params
    {
      client_id: CONFIGS[:client_id],
      client_secret: CONFIGS[:client_secret],
      redirect_uri: @options[:redirect_uri],
      code: @options[:code],
      grant_type: PREDEFINED_REQUEST_PARAMS[:grant_type]
    }
  end
end
