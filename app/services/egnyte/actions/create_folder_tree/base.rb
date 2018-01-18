class Egnyte::Actions::CreateFolderTree::Base
  CONFIGS = {
    client_id: ENV['egnyte_client_id'],
    client_secret: ENV['egnyte_client_secret']
  }.freeze

  class << self
    def required_option_keys
      @required_option_keys ||= %i(egnyte_integration_id root_name)
    end

    def folder_tree_attribute_name
      raise NotImplementedError, __method__
    end

    def root_folder_path_prefix
      raise NotImplementedError, __method__
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    traverse_folder_tree(folder_tree) do |node|
      create_folder_request(
        domain: @options[:domain],
        folder_path: "#{root_folder_path_prefix}/#{node[:title]}",
        access_token: access_token
      )
    end
  end

  private

  delegate :required_option_keys, :folder_tree_attribute_name, :root_folder_path_prefix, to: self

  def traverse_folder_tree(node, &block)
    block.call(node)

    return if node[:nodes].blank?

    node[:nodes].each do |child|
      # Prefix child folder name with parent folder name
      child[:title] = "#{node[:title]}/#{child[:title]}"

      traverse_folder_tree(child, &block)
    end
  end

  def folder_tree
    egnyte_integration
      .send(folder_tree_attribute_name)
      .deep_dup
      .deep_symbolize_keys!
      .tap do |folder_tree|
        # Override top folder name with a provided 'root_name' option
        folder_tree[:title] = @options[:root_name]
      end
  end

  def create_folder_request(options)
    Egnyte::Endpoints::CreateFolder.new(options).tap { |req| req.perform }
  end

  def access_token
    egnyte_integration.access_token
  end

  def egnyte_integration
    @egnyte_integration ||= EgnyteIntegration.find(@options[:egnyte_integration_id])
  end
end
