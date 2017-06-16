class AddReadOnlyToBp < ActiveRecord::Migration
  def change
    add_column :bps, :read_only, :boolean, default: false
  end
end
