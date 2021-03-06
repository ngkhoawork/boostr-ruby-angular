class Egnyte::PrivateActions::BuildAccountFolderPath < Egnyte::Actions::Base
  class << self
    def required_option_keys
      @required_option_keys ||= %i()
    end

    def app_folder_path
      '/Shared/Boostr'
    end
  end

  def perform
    return app_folder_path unless @options[:client_id]

    recursive_build(
      Client.find(@options[:client_id])
    )
  end

  private

  delegate :app_folder_path, :new, to: :class

  def recursive_build(record)
    return stored_folder_path(record) if record.egnyte_folder&.path

    parent_folder_path =
      if record.parent_client_id
        recursive_build(record.parent_client)
      else
        app_folder_path
      end

    folder_path = File.join(parent_folder_path, 'Accounts', sanitize_folder_name(record.name))

    @options[:ensure_folders] ? ensure_account_folder(record.id, folder_path) : folder_path
  end

  def stored_folder_path(record)
    if @options[:ensure_folders]
      ensure_account_folder(record.id, record.egnyte_folder&.path)
    else
      record.egnyte_folder&.path
    end
  end

  def ensure_account_folder(client_id, pattern_path)
    Egnyte::PrivateActions::EnsureAccountFolder.new(client_id: client_id, pattern_path: pattern_path).perform
  end
end
