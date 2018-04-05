class Egnyte::Actions::UpdateFolderName::Base
  def self.required_option_keys
    raise NotImplementedError, __method__
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    return false unless enabled_and_connected? && egnyte_folder&.uuid

    update_folder_name_response

    update_folder_path
  end

  private

  delegate :required_option_keys, to: :class
  delegate :access_token, :app_domain, :deals_folder_name, :enabled_and_connected?, to: :egnyte_integration

  def update_folder_name_response
    Egnyte::Endpoints::MoveFolder.new(
      app_domain,
      destination: root_folder_path,
      folder_id: egnyte_folder.uuid,
      access_token: access_token
    ).perform
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

  def record
    raise NotImplementedError, __method__
  end

  def root_folder_path
    raise NotImplementedError, __method__
  end
end
