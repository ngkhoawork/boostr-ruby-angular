class AddDealsLabelToEgnyteFolders < ActiveRecord::Migration
  def up
    add_column :egnyte_integrations, :deals_folder_name, :string
    change_column :egnyte_integrations, :deal_folder_tree, :jsonb, null: true, default: nil
    change_column :egnyte_integrations, :account_folder_tree, :jsonb, null: true, default: nil
  end

  def down
    remove_column :egnyte_integrations, :deals_folder_name
    change_column :egnyte_integrations, :deal_folder_tree, :jsonb, null: false, default: old_deal_folder_tree_default
    change_column :egnyte_integrations, :account_folder_tree, :jsonb, null: false, default: old_account_folder_tree_default
  end

  private

  def old_deal_folder_tree_default
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

  def old_account_folder_tree_default
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
