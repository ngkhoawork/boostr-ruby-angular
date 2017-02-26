class Operative::AuthDetailsService
  def initialize(api_config)
    @api_config = api_config
  end

  def perform
    get_connection_attribute
  end

  private

  attr_reader :api_config

  def get_connection_attribute
    {
        base_url: api_config.base_link,
        user_email: api_config.api_email,
        password: api_config.password,
        company_id: api_config.company_id,
    }
  end
end
