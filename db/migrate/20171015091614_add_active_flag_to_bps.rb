class AddActiveFlagToBps < ActiveRecord::Migration
  def change
    add_column :bps, :active, :boolean, default: true
  end
end
