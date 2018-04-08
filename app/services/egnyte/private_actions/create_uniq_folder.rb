class Egnyte::PrivateActions::CreateUniqFolder < Egnyte::Actions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(path egnyte_integration)
  end

  def perform
    response = api_caller.create_folder(folder_path: @options[:path], access_token: access_token)

    if response.folder_already_exists?
      @options[:path] = build_uniq_path

      api_caller.create_folder(folder_path: @options[:path], access_token: access_token)
    end

    @options[:path]
  end

  private

  def parent_path
    @options[:path].sub(/\/[\w ]+(?:\/)?\z/, '')
  end

  def build_uniq_path
    response = api_caller.get_folder_by_path(folder_path: parent_path, access_token: access_token)

    related_folder_names =
      response.body[:folders].map { |folder| folder[:name] }.grep(/#{Regexp.escape(folder_name)}/)

    latest_version = extract_folders_versions(related_folder_names).max

    attach_version_to_path(@options[:path], latest_version + 1)
  end

  def folder_name
    @options[:path].match(/(?<=\/)[\w ]+\z/)[0]
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
