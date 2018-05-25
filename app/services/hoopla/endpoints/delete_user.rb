class Hoopla::Endpoints::DeleteUser < Hoopla::Endpoints::AuthorizedResource
  def self.required_option_keys
    super + %i(href)
  end

  private

  def request_method
    :delete
  end

  def path
    @options[:href]
  end

  def resource_name
    'user'
  end
end
