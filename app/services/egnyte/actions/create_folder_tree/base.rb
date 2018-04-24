class Egnyte::Actions::CreateFolderTree::Base < Egnyte::Actions::Base
  def perform
    return false unless enabled?

    root_folder_struct[:path] = create_uniq_folder(root_folder_struct[:path])

    traverse_folder_nodes(root_folder_struct) do |node|
      node[:path] = create_uniq_folder(node[:path])
    end

    save_root_folder(root_folder_struct[:path])
  end

  private

  delegate :folder_tree_attr_name, to: :class

  def traverse_folder_nodes(node, &block)
    node[:nodes].each do |child|
      child[:path] = File.join(node[:path], child[:title])

      block.call(child)

      traverse_folder_nodes(child, &block)
    end
  end

  def root_folder_struct
    @root_folder_struct ||= default_folder_struct.tap { |folder_tree| folder_tree[:path] = root_folder_path }
  end

  def default_folder_struct
    egnyte_integration
      .public_send(folder_tree_attr_name)
      .deep_dup
      .deep_symbolize_keys!
  end

  def save_root_folder(path)
    response = api_caller.get_folder_by_path(folder_path: path, access_token: access_token)

    folder.update(uuid: response.body[:folder_id], path: response.body[:path])
  end

  def create_uniq_folder(path_template)
    Egnyte::PrivateActions::CreateUniqFolder.new(egnyte_integration: egnyte_integration, path: path_template).perform
  end

  def folder
    @folder ||= record.egnyte_folder || record.build_egnyte_folder
  end
end
