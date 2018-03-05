class Egnyte::Actions::UpdateFolderName::Base
  ENCODED_SPACE_SIGN = '%20'.freeze

  def self.required_option_keys
    raise NotImplementedError, __method__
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    return false unless enabled_and_connected? && egnyte_folder&.uuid

    update_folder_name_request

    update_folder_path
  end

  private

  delegate :required_option_keys, to: :class
  delegate :access_token, :app_domain, :enabled_and_connected?, to: :egnyte_integration

  def update_folder_name_request
    Egnyte::Endpoints::MoveFolder.new(
      destination: root_folder_path,
      folder_id: egnyte_folder.uuid,
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def update_folder_path
    egnyte_folder.update(path: root_folder_path)
  end

  def egnyte_integration
    @egnyte_integration ||= EgnyteIntegration.find(@options[:egnyte_integration_id])
  end

  def egnyte_folder
    @egnyte_folder ||= record.egnyte_folder
  end

  def encode_space_sign(str)
    str.gsub(/ /, ENCODED_SPACE_SIGN)
  end

  def record
    raise NotImplementedError, __method__
  end

  def root_folder_path
    raise NotImplementedError, __method__
  end
end
