class AddTypeIdToPublishers < ActiveRecord::Migration
  def change
    add_column :publishers, :type_id, :integer
    add_index :publishers, :type_id
  end
end
