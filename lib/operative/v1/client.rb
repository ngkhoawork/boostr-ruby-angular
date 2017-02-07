module Operative
  module V1
    class Client
      attr_reader :connection, :config

      def initialize(options = {})
        @connection = Operative::V1::Connection.new(options).init
        @config = Operative::V1::Configuration.new
      end

      def method_missing(method_name, **options)
        mapping = methods_mapping.select { |mapping| mapping[:name] == method_name.to_s }[0]
        if mapping.any?
          connection.send(:"#{mapping[:http][:request_type]}", mapping[:http][:endpoint], options[:params])
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