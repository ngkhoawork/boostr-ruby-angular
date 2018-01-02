class AddPublisherIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :publisher_id, :integer
    add_index :contacts, :publisher_id
  end
end
