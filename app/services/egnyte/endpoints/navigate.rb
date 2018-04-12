class Egnyte::Endpoints::Navigate < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(folder_path access_token)
    end

    def predefined_request_params
      { embedded: true }
    end
  end

  private

  delegate :predefined_request_params, to: :class

  def request_method
    :post
  end

  def path
    'pubapi/v2/navigate'
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end

  def request_params
    {
      path: @options[:folder_path],
      embedded: true
    }
  end
end
