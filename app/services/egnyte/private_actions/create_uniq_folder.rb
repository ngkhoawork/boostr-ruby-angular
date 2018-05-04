class Egnyte::PrivateActions::CreateUniqFolder < Egnyte::Actions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(path egnyte_integration)
  end

  def perform
    response = api_caller.create_folder(folder_path: @options[:path], access_token: access_token)

    if response.success?
      @options[:path]
    elsif response.folder_already_exists?
      uniq_path = build_uniq_path(@options[:path])

      api_caller.create_folder(folder_path: uniq_path, access_token: access_token)
      uniq_path
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end

  private

  def build_uniq_path(path_template)
    neighbor_folder_names = neighbor_folders(path_template).map { |folder| folder[:name] }

    related_names = grep_names(neighbor_folder_names, path_template)

    latest_version = extract_folders_versions(related_names).max

    attach_version_to_path(path_template, latest_version + 1)
  end

  def folder_name(path)
    path.match(/(?<=\/)[\w ]+\z/)[0]
  end

  def parent_path(path)
    path.sub(/\/[\w ]+(?:\/)?\z/, '')
  end

  def grep_names(neighbor_names, path)
    neighbor_names.grep(/#{Regexp.escape(folder_name(path))}/)
  end

  def neighbor_folders(path)
    response = api_caller.get_folder_by_path(
      folder_path: parent_path(path),
      access_token: access_token
    )

    if response.success?
      response.body[:folders]
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end

  def extract_folders_versions(folder_names)
    folder_names
      .map { |folder_name| folder_name.match(/\A[\w ]+(?:~(?<version>[\d]+))?\z/) }
      .compact
      .map! { |match| match[1].to_i }
  end

  def attach_version_to_path(path, version)
    path.sub(/(?<=\w)(?:~[\d]+)?\z/, "~#{version}")
  end
end
