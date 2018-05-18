class Hoopla::Endpoints::CreateNewsflash < Hoopla::Endpoints::AuthorizedResource
  def self.required_option_keys
    super + %i(name icon_src)
  end

  private

  def request_method
    :post
  end

  def path
    'newsflashes'
  end

  def request_params
    {
      name: @options[:name],
      icon_src: @options[:icon_src]
    }
  end

  def resource_name
    'newsflash'
  end
end
