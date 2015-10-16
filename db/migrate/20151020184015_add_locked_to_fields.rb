class AddLockedToFields < ActiveRecord::Migration
  def change
    add_column :fields, :locked, :boolean
  end
end
