class AddUuidToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :uuid, :string
  end
end
