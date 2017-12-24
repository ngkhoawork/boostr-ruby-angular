class Api::V2::CalendarExtensionController < ApiController
  def index
    response.headers["Content-Type"] = "text/html; charset=utf-8"
    response.headers["Content-Security-Policy"] = ""
    response.headers.delete("X-Frame-Options")
  end
end