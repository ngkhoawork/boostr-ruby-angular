class Egnyte::Actions::UpdateFolder::Base < Egnyte::Actions::Base
  def perform
    return false unless enabled? && folder&.uuid

    api_caller.move_folder(destination: root_folder_path, folder_id: folder.uuid, access_token: access_token)

    folder.update(path: root_folder_path)
  end

  private

  def folder
    @folder ||= record.egnyte_folder
  end
end
