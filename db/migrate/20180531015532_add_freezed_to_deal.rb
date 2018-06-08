class AddFreezedToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :freezed, :boolean, default: false
  end
end
