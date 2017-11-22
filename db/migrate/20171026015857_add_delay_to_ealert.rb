class AddDelayToEalert < ActiveRecord::Migration
  def change
    add_column :ealerts, :delay, :integer, default: 60
  end
end
