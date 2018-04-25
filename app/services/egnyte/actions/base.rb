class Egnyte::Actions::Base
  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  private

  delegate :required_option_keys, to: :class
  delegate :state_token, :access_token, :app_domain, :deals_folder_name, :enabled?, to: :egnyte_integration

  def api_caller
    @api_caller ||= Egnyte::Endpoints::ApiCaller.new(app_domain)
  end

  def egnyte_integration
    @egnyte_integration ||= @options[:egnyte_integration] || EgnyteIntegration.find(@options[:egnyte_integration_id])
  end

  def sanitize_folder_name(folder_name)
    Egnyte::Lib::SanitizeFolderName.perform(folder_name)
  end
end
