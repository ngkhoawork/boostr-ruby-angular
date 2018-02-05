module Operative
  module V2
    class Connection
      attr_reader :base_url, :user_email, :password, :company_id

      def initialize(options = {})
        @base_url = options[:base_url]
        @user_email = options[:user_email]
        @password = options[:password]
        @company_id = options[:company_id]
      end

      def init
        Faraday.new(url: base_url) do |faraday|
          faraday.headers['companyId'] = company_id.to_s
          faraday.headers['Content-Type'] = 'application/xml'
          faraday.headers['Accept'] = 'application/xml'
          faraday.headers['version'] = 'v2'
          faraday.headers['apiProvider'] = 'operative'
          faraday.response :logger unless Rails.env.test?
          faraday.use Operative::IntegrationLoggingMiddleware
          faraday.basic_auth(user_email, password)
          faraday.adapter  Faraday.default_adapter
        end
      end
    end
  end
end
