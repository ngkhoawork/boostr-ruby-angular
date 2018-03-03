class Egnyte::Actions::CreateFolderTree::Base
  ENCODED_SPACE_SIGN = '%20'.freeze

  class << self
    def required_option_keys
      raise NotImplementedError, __method__
    end

    def folder_tree_attribute_name
      raise NotImplementedError, __method__
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    return false unless enabled_and_connected?

    traverse_folder_tree(root_folder) do |node|
      create_folder_request(folder_path: node[:path], domain: app_domain, access_token: access_token)
    end

    save_root_folder
  end

  private

  delegate :required_option_keys, :folder_tree_attribute_name, to: :class
  delegate :access_token, :app_domain, :enabled_and_connected?, to: :egnyte_integration

  def traverse_folder_tree(node, &block)
    block.call(node)

    node[:nodes].each do |child|
      child[:path] = build_folder_path(node[:path], child[:title])

      traverse_folder_tree(child, &block)
    end
  end

  def root_folder
    folder_tree_pattern.tap { |folder_tree| folder_tree[:path] = root_folder_path }
  end

  def folder_tree_pattern
    egnyte_integration
      .send(folder_tree_attribute_name)
      .deep_dup
      .deep_symbolize_keys!
  end

  def build_folder_path(parent_folder_path, child_folder_title)
    File.join(
      parent_folder_path,
      encode_space_sign(child_folder_title)
    )
  end

  def save_root_folder
    egnyte_folder.update(
      uuid: get_root_folder_request.parsed_response_body[:folder_id],
      path: get_root_folder_request.parsed_response_body[:path]
    )
  end

  def create_folder_request(options)
    Egnyte::Endpoints::CreateFolder.new(options).tap { |req| req.perform }
  end

  def get_root_folder_request
    @get_root_folder_request ||= Egnyte::Endpoints::GetFolderByPath.new(
      folder_path: root_folder[:path],
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def egnyte_integration
    @egnyte_integration ||= EgnyteIntegration.find(@options[:egnyte_integration_id])
  end

  def encode_space_sign(str)
    str.gsub(/ /, ENCODED_SPACE_SIGN)
  end

  def egnyte_folder
    @egnyte_folder ||= record.egnyte_folder || record.build_egnyte_folder
  end

  def record
    raise NotImplementedError, __method__
  end

  def root_folder_path
    raise NotImplementedError, __method__
  end
end
