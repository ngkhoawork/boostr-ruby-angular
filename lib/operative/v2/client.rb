module Operative
  module V2
    class Client
      attr_reader :connection, :config

      def initialize(options = {})
        @connection = Operative::V2::Connection.new(options).init
        @config = Operative::V2::Configuration.new
      end

      def method_missing(method_name, **options)
        mapping = methods_mapping.select { |mapping| mapping[:name] == method_name.to_s }[0]
        if mapping.any?
          endpoint = mapping[:http][:endpoint]
          request_type = mapping[:http][:request_type]

          split_endpoint = endpoint.split('/')
          endpoint_params = split_endpoint.grep(/:/)

          if endpoint_params.any?
            endpoint_params.each do |req_param|
              req_param_sym = req_param.gsub(':', '').to_sym
              raise ArgumentError, "You need to specify #{req_param} option to proceed" unless options.has_key? req_param_sym
              endpoint.gsub!( req_param, options[req_param_sym].to_s )
            end
          end
          connection.send(:"#{ request_type }", endpoint, options[:params])
        else
          super
        end
      end

      def methods_mapping
        configuration = config.read.deep_symbolize_keys
        configuration.fetch(:resources)
      end
    end
  end
end
