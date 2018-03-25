class Egnyte::Actions::GetNavigateUri::Base
  def self.required_option_keys
    raise NotImplementedError, __method__
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    return unless enabled_and_connected? && egnyte_folder&.path

    response = navigate_request

    return response.parsed_response_body[:redirect] if response.success?

    if response.response_code == '400'
      update_folder_path

      response = navigate_request

      return response.parsed_response_body[:redirect] if response.success?
    end

    raise Egnyte::Errors::UnhandledRequest
  end

  private

  delegate :required_option_keys, to: :class
  delegate :access_token, :app_domain, :deals_folder_name, :enabled_and_connected?, to: :egnyte_integration

  def navigate_request
    Egnyte::Endpoints::Navigate.new(
      folder_path: folder_path,
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def get_folder_request
    @get_folder_request ||= Egnyte::Endpoints::GetFolderById.new(
      folder_id: egnyte_folder.uuid,
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def update_folder_path
    egnyte_folder.update(path: get_folder_request.parsed_response_body[:path])
  end

  def egnyte_integration
    @egnyte_integration ||= EgnyteIntegration.find(@options[:egnyte_integration_id])
  end

  def egnyte_folder
    @egnyte_folder ||= record.egnyte_folder
  end

  def record
    raise NotImplementedError, __method__
  end

  def folder_path
    raise NotImplementedError, __method__
  end
end
