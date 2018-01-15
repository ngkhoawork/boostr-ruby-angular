class Egnyte::Actions::BuildUserAuthorizationUri
  CONFIGS = {
    client_id: ENV['egnyte_client_id'],
    client_secret: ENV['egnyte_client_secret']
  }.freeze

  PREDEFINED_REQUEST_PARAMS = {
    scope: 'Egnyte.filesystem Egnyte.launchwebsession',
    response_code: 'code'
  }.freeze

  REQUIRED_OPTIONS = %i(domain redirect_uri state).freeze

  def initialize(options)
    @options = options.deep_symbolize_keys

    REQUIRED_OPTIONS.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  def perform
    "https://#{@options[:domain]}/puboauth/token?#{URI.encode_www_form(request_params)}"
  end

  private

  def request_params
    {
      redirect_uri: @options[:redirect_uri],
      state: @options[:state],
      client_id: CONFIGS[:client_id],
      client_secret: CONFIGS[:client_secret],
      scope: PREDEFINED_REQUEST_PARAMS[:scope],
      response_type: PREDEFINED_REQUEST_PARAMS[:response_code]
    }
  end
end
