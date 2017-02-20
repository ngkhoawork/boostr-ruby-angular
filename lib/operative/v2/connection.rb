module Operative
  module V2
    class Connection
      attr_reader :base_url, :user_email, :password

      def initialize(options = {})
        @base_url = options[:base_url]
        @user_email = options[:user_email]
        @password = options[:password]
      end

      def init
        Faraday.new(url: base_url) do |faraday|
          faraday.headers['Content-Type'] = 'application/xml'
          faraday.headers['Accept'] = 'application/xml'
          faraday.headers['version'] = 'v2'
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
          faraday.basic_auth(user_email, password)
        end
      end
    end
  end
end
