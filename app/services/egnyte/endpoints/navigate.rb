class Egnyte::Endpoints::Navigate < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain folder_path access_token)
    end

    def predefined_request_params
      { embedded: true }
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  private

  delegate :required_option_keys, :predefined_request_params, to: :class

  def request_method
    :post
  end

  def domain
    @options[:domain].sub(/https?:\/\//, '')
  end

  def path
    'pubapi/v2/navigate'
  end

  def request_params
    {
      path: @options[:folder_path],
      embedded: true
    }
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end
end
