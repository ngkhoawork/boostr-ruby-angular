module Operative
  module V1
    class Connection
      BASE_URL = 'https://config.operativeone.com'
      USERNAME = 'api_user@kingsandbox.com'
      PASSWORD = 'King2017!'

      attr_reader :base_url

      def initialize(options = {})
        @base_url = options[:base_url] || BASE_URL
      end

      def init
        conn = Faraday.new(url: base_url)
        conn.basic_auth(USERNAME, PASSWORD)
        conn
      end
    end
  end
end
