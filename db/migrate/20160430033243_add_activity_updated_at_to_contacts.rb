class AddActivityUpdatedAtToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :activity_updated_at, :datetime
  end
end
