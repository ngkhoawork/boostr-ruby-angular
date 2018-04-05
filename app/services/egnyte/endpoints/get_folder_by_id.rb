class Egnyte::Endpoints::GetFolderById < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(folder_id access_token)
    end
  end

  private

  def request_method
    :get
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
end
