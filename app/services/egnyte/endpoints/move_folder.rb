class Egnyte::Endpoints::MoveFolder < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(folder_id destination access_token)
    end

    def predefined_request_params
      { action: 'move' }
    end
  end

  private

  delegate :predefined_request_params, to: :class

  def request_method
    :post
  end

  def path
    "pubapi/v1/fs/ids/folder/#{@options[:folder_id]}"
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end

  def request_params
    {
      destination: @options[:destination],
      action: predefined_request_params[:action],
    }
  end
end
