class Egnyte::PrivateActions::CreateUniqFolder < Egnyte::PrivateActions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(path egnyte_integration)
  end

  def perform
    if create_folder_request(@options[:path]).folder_already_exists?
      parent_folder_info = get_folder_by_path_request(parent_path).parsed_response_body

      related_folder_names =
        parent_folder_info[:folders].map { |folder| folder[:name] }.grep(/#{Regexp.escape(folder_name)}/)

      last_version = extract_folders_versions(related_folder_names).max

      @options[:path] = attach_version_to_path(@options[:path], last_version + 1)

      create_folder_request(@options[:path])
    end

    @options[:path]
  end

  private

  delegate :access_token, :app_domain, to: :egnyte_integration

  def create_folder_request(path)
    Egnyte::Endpoints::CreateFolder.new(
      folder_path: path,
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def get_folder_by_path_request(path)
    Egnyte::Endpoints::GetFolderByPath.new(
      folder_path: path,
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def parent_path
    @options[:path].sub(/\/[\w ]+(?:\/)?\z/, '')
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

  def egnyte_integration
    @options[:egnyte_integration]
  end
end
