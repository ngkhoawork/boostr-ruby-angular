class AddPublisherIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :publisher_id, :integer
    add_index :activities, :publisher_id
  end
end
