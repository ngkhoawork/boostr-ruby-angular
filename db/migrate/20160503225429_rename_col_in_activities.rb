class RenameColInActivities < ActiveRecord::Migration
  def change
    rename_column :activities, :activity_type, :activity_type_name
  end
end
