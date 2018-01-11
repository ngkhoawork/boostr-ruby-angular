class EgnyteService
  #TODO
  API_KEY = "d79k62ecxmejnt5t7kdp7pnh"
  CLIENT_SECRET = "RkhkdQ9JWg6vnz8BBpWvX799Tfc58ssCvYrYQF9gj2aNRAJHTQ"
  DOMAIN = "appboostrcrm.qa-egnyte.com"

  def initialize

  end

  def get_egnyte_code
    redirect_uri = "https://192.168.2.127:3000/api/egnyte_oauth_callback"

    result_url = URI("https://appboostrcrm.qa-egnyte.com/puboauth/token?client_id=#{API_KEY}&client_secret=#{CLIENT_SECRET}&redirect_uri=#{redirect_uri}&scope=#{egnyte_creds[:scope]}&response_type=#{egnyte_creds[:response_type]}")
    result_url.to_s
  end



  private

  def egnyte_creds
    {
      egnyte_uri: "/puboauth/token",
      redirect_uri: "https://boostr-testing.herokuapp.com/users/sign_in",
      scope: "Egnyte.launchwebsession",
      response_type: "token"
    }
  end
end