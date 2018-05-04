class AddDealsFolderToAccountsTree < ActiveRecord::Migration
  def change
    EgnyteIntegration.find_each do |ei|
      ei.account_folder_tree['nodes'] << { 'title' => ei.deals_folder_name, 'nodes' => [] }
      ei.save
    end
  end
end
