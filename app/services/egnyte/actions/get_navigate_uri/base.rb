class Egnyte::Actions::GetNavigateUri::Base < Egnyte::Actions::Base
  def perform
    return unless enabled_and_connected? && egnyte_folder

    if egnyte_folder.path
      navigate || update_path_and_navigate
    else
      update_path_and_navigate
    end
  end

  private

  def navigate
    response = api_caller.navigate(folder_path: folder_path, access_token: access_token)

    if response.success?
      response.body[:redirect]
    elsif response.bad_request?
      nil
    else
      raise Egnyte::Errors::UnhandledRequest
    end
  end

  def update_path_and_navigate
    update_folder_path

    navigate
  end

  def update_folder_path
    response = api_caller.get_folder_by_id(folder_id: egnyte_folder.uuid, access_token: access_token)

    egnyte_folder.update(path: response.body[:path])
  end

  def egnyte_folder
    @egnyte_folder ||= record.egnyte_folder
  end
end
