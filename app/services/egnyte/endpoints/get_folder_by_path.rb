class Egnyte::Endpoints::GetFolderByPath < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(folder_path access_token)
    end
  end

  private

  def request_method
    :get
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
end
