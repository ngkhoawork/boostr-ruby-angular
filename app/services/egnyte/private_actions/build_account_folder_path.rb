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

    recursive_build(@options[:client_id])
  end

  private

  delegate :app_folder_path, :new, to: :class

  def recursive_build(client_id)
    record = Client.find(client_id)

    parent_folder_path =
      if record.parent_client_id
        recursive_build(record.parent_client_id)
      else
        app_folder_path
      end

    folder_path = File.join(parent_folder_path, 'Accounts', record.name)

    @options[:ensure_folders] ? ensure_account_folder(record.id, folder_path) : folder_path
  end

  def ensure_account_folder(client_id, pattern_path)
    Egnyte::PrivateActions::EnsureAccountFolder.new(client_id: client_id, pattern_path: pattern_path).perform
  end
end
