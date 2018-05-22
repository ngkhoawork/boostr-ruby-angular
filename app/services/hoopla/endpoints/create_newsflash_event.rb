class Hoopla::Endpoints::CreateNewsflashEvent < Hoopla::Endpoints::AuthorizedResource
  def self.required_option_keys
    super + %i(newsflash_href user_href title message)
  end

  private

  def request_method
    :post
  end

  def path
    "#{@options[:newsflash_href]}/events"
  end

  def request_params
    {
      title: @options[:title],
      message: @options[:message],
      owner: {
        kind: 'user',
        href: @options[:user_href]
      }
    }
  end

  def resource_name
    'newsflash-event'
  end
end
