module Operative
  module V1
    class Connection

      attr_reader :base_url, :user_email, :password

      def initialize(options = {})
        @base_url = options[:base_url]
        @user_email = options[:user_email]
        @password = options[:password]
      end

      def init
        conn = Faraday.new(url: base_url)
        conn.basic_auth(user_email, password)
        conn
      end
    end
  end
end
