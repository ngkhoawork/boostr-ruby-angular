class Egnyte::Endpoints::CreateFolder < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(folder_path access_token)
    end

    def predefined_request_params
      { action: 'add_folder' }
    end
  end

  private

  delegate :predefined_request_params, to: :class

  def request_method
    :post
  end

  def path
    "pubapi/v1/fs/#{@options[:folder_path]}"
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end

  def request_params
    {
      action: predefined_request_params[:action]
    }
  end
end
