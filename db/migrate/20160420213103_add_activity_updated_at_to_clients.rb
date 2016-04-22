class AddActivityUpdatedAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :activity_updated_at, :datetime
  end
end
