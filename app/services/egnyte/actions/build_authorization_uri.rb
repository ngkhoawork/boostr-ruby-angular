class Egnyte::Actions::BuildAuthorizationUri
  CONFIGS = {
    client_id: ENV['egnyte_client_id'],
    client_secret: ENV['egnyte_client_secret']
  }.freeze
  REQUESTED_ACCESS_TOKEN_MARKER = 'SHOULD_BE_REPLACED_WITH_ACCESS_TOKEN'.freeze

  class << self
    def generate_state_token(salt)
      random_hash = Digest::MD5.hexdigest("#{DateTime.current}-#{salt}")

      "#{REQUESTED_ACCESS_TOKEN_MARKER}_#{random_hash}"
    end

    def required_option_keys
      @required_option_keys ||= %i(domain redirect_uri state)
    end

    def predefined_request_params
      {
        scope: 'Egnyte.filesystem Egnyte.launchwebsession',
        response_code: 'code'
      }
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  def perform
    "https://#{@options[:domain]}/puboauth/token?#{url_embedded_request_params}"
  end

  private

  delegate :required_option_keys, :predefined_request_params, to: :class

  def url_embedded_request_params
    request_params.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  def request_params
    {
      redirect_uri: @options[:redirect_uri],
      state: @options[:state],
      client_id: CONFIGS[:client_id],
      client_secret: CONFIGS[:client_secret],
      scope: predefined_request_params[:scope],
      response_type: predefined_request_params[:response_code]
    }
  end
end
