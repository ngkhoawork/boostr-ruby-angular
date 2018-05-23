class Hoopla::Endpoints::AuthorizedResource < Hoopla::Endpoints::Request
  def self.required_option_keys
    %i(access_token)
  end

  private

  def request_headers
    {
      'Authorization' => "Bearer #{@options[:access_token]}",
      'Content-Type' => "application/vnd.hoopla.#{resource_name}+json",
      'Accept' => "application/vnd.hoopla.#{resource_name}+json"
    }
  end
end
