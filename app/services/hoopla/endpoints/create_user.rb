class Hoopla::Endpoints::CreateUser < Hoopla::Endpoints::AuthorizedResource
  def self.required_option_keys
    super + %i(first_name last_name email)
  end

  private

  def request_method
    :post
  end

  def path
    'users'
  end

  def request_params
    {
      first_name: @options[:first_name],
      last_name: @options[:last_name],
      email: @options[:email]
    }
  end

  def resource_name
    'user'
  end
end
