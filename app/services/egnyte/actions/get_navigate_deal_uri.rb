class Egnyte::Actions::GetNavigateDealUri
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id deal_id)
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

    raise 'Unhandled request'
  end

  private

  delegate :required_option_keys, to: :class
  delegate :access_token, :app_domain, :enabled_and_connected?, to: :egnyte_integration

  def navigate_request
    Egnyte::Endpoints::Navigate.new(
      folder_path: egnyte_folder.path,
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
    @egnyte_folder ||= deal.egnyte_folder
  end

  def deal
    Deal.find(@options[:deal_id])
  end

  def encode_space_sign(str)
    str.gsub(/ /, ENCODED_SPACE_SIGN)
  end
end
