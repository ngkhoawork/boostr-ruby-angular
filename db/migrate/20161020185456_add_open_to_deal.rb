class AddOpenToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :open, :boolean, default: true
  end
end
