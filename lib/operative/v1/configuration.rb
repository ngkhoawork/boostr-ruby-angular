module Operative
  module V1
    class Configuration
      BASE_CONFIG_PATH = File.expand_path('../../config/operative.v1.json', __FILE__)

      def initialize(options = {})
        @config_path = options[:config_path] || BASE_CONFIG_PATH
      end

      def read
        file = File.read(config_path)
        JSON.parse(file)
      end

      private

      attr_reader :config_path

    end
  end
end