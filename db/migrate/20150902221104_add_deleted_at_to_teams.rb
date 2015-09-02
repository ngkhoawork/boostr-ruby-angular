class AddDeletedAtToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :deleted_at, :datetime
    add_index :teams, :deleted_at
  end
end
