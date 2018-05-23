class Hoopla::Endpoints::GetNewsflashes < Hoopla::Endpoints::AuthorizedResource
  private

  def request_method
    :get
  end

  def path
    'newsflashes'
  end

  def resource_name
    'newsflash-list'
  end
end
