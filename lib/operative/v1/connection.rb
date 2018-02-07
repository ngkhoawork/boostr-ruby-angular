module Operative
  module V1
    class Connection

      attr_reader :base_url, :user_email, :password, :company_id

      def initialize(options = {})
        @base_url = options[:base_url]
        @user_email = options[:user_email]
        @password = options[:password]
        @company_id = options[:company_id]
      end

      def init
        Faraday.new(url: base_url) do |connection|
          connection.headers['companyId'] = company_id.to_s
          connection.headers['apiProvider'] = 'operative'
          connection.basic_auth(user_email, password)
          connection.request  :url_encoded
          connection.use Operative::IntegrationLoggingMiddleware
          connection.response :logger unless Rails.env.test?
          connection.adapter  Faraday.default_adapter
        end
      end
    end
  end
end
