module Operative
  module V2
    class Connection
      BASE_URL = 'https://config.operativeone.com'
      USERNAME = 'api_user@kingsandbox.com'
      PASSWORD = 'King2017!'

      attr_reader :base_url

      def initialize(options = {})
        @base_url = options[:base_url] || BASE_URL
      end

      def init
        Faraday.new(url: base_url) do |faraday|
          faraday.headers['Content-Type'] = 'application/xml'
          faraday.headers['Accept'] = 'application/xml'
          faraday.headers['version'] = 'v2'
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
          faraday.basic_auth(USERNAME, PASSWORD)
        end
      end
    end
  end
end
