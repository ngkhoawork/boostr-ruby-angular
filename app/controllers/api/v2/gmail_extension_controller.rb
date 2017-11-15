class Api::V2::GmailExtensionController < ApiController
  def index
    @cert = request.ssl? ? "https://" : "http://"
    if request.domain == 'localhost'
      @domain = @cert + request.domain + ":#{request.port}"
    else
      @domain = @cert + request.domain
    end
    
    response.headers["Content-Type"] = "text/html; charset=utf-8"
  end
end