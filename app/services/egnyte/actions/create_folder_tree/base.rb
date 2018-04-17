class Egnyte::Actions::CreateFolderTree::Base < Egnyte::Actions::Base
  def perform
    return false unless enabled?

    traverse_folder_tree(root_folder) do |node|
      node[:path] = create_uniq_folder(node[:path])
    end

    save_root_folder
  end

  private

  delegate :folder_tree_attr_name, to: :class

  def traverse_folder_tree(node, &block)
    block.call(node)

    node[:nodes].each do |child|
      child[:path] = File.join(node[:path], child[:title])

      traverse_folder_tree(child, &block)
    end
  end

  def root_folder
    folder_tree_pattern.tap { |folder_tree| folder_tree[:path] = root_folder_path }
  end

  def folder_tree_pattern
    egnyte_integration
      .public_send(folder_tree_attr_name)
      .deep_dup
      .deep_symbolize_keys!
  end

  def save_root_folder
    response = api_caller.get_folder_by_path(folder_path: root_folder[:path], access_token: access_token)

    folder.update(uuid: response.body[:folder_id], path: response.body[:path])
  end

  def create_uniq_folder(path)
    Egnyte::PrivateActions::CreateUniqFolder.new(egnyte_integration: egnyte_integration, path: path).perform
  end

  def folder
    @folder ||= record.egnyte_folder || record.build_egnyte_folder
  end
end
