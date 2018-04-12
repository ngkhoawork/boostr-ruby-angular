class RenameIsFreezedToFreezedInIo < ActiveRecord::Migration
  def change
    rename_column :ios, :is_freezed, :freezed
  end
end
