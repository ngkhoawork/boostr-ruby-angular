class Api::V2::GmailExtensionController < ApiController
  def index
    if request.domain == 'localhost'
      @domain = request.domain + ":#{request.port}"
    else
      @domain = request.domain
    end
    
    response.headers["Content-Type"] = "application/html"
  end
end