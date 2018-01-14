class EgnyteService
  def initialize(company, request)
    @api_key = company.egnyte_client_id
    @client_secret = company.egnyte_client_secret
    @egnyte_domain = company.egnyte_app_domain
    @current_host = request.base_url

  end

  def get_egnyte_code
    redirect_uri = "#{@current_host}/api/egnyte_oauth_callback"

    result_url = URI("https://#{@egnyte_domain}/puboauth/token?client_id=#{@api_key}&client_secret=#{@client_secret}&redirect_uri=#{redirect_uri}&scope=#{egnyte_creds[:scope]}&response_type=#{egnyte_creds[:response_type]}")
    result_url.to_s
  end



  private

  def egnyte_creds
    {
      scope: "Egnyte.launchwebsession",
      response_type: "token"
    }
  end
end