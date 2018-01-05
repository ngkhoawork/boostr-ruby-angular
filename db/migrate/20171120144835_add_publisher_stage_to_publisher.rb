class AddPublisherStageToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :stage_id, :integer
    add_index :publishers, :stage_id
  end
end
