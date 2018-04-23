class Egnyte::Actions::UpdateFolder::Base < Egnyte::Actions::Base
  def perform
    return false unless enabled_and_connected? && egnyte_folder&.uuid

    api_caller.move_folder(destination: root_folder_path, folder_id: egnyte_folder.uuid, access_token: access_token)

    egnyte_folder.update(path: root_folder_path)
  end

  private

  def egnyte_folder
    @egnyte_folder ||= record.egnyte_folder
  end
end
