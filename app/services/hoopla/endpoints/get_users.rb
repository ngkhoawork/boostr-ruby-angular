class Hoopla::Endpoints::GetUsers < Hoopla::Endpoints::AuthorizedResource
  private

  def request_method
    :get
  end

  def path
    'users'
  end

  def resource_name
    'user-list'
  end
end
