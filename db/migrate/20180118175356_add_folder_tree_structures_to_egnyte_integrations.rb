class AddFolderTreeStructuresToEgnyteIntegrations < ActiveRecord::Migration
  def change
    add_column :egnyte_integrations, :deal_folder_tree, :jsonb, null: false, default: deal_folder_tree_default
    add_column :egnyte_integrations, :account_folder_tree, :jsonb, null: false, default: account_folder_tree_default
  end

  private

  def deal_folder_tree_default
    {
      title: 'Deal',
      nodes: [
        {
          title: 'RFP',
          nodes: []
        },
        {
          title: 'Proposal',
          nodes: []
        },
        {
          title: 'Creative',
          nodes: []
        }
      ]
    }
  end

  def account_folder_tree_default
    {
      title: 'Account',
      nodes: [
        {
          title: 'Contract',
          nodes: []
        },
        {
          title: 'Templates',
          nodes: []
        }
      ]
    }
  end
end
