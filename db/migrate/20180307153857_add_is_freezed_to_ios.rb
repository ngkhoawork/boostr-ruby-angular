class AddIsFreezedToIos < ActiveRecord::Migration
  def change
    add_column :ios, :is_freezed, :boolean, default: false
  end
end
