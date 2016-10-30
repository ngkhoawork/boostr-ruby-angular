class AddNameToIo < ActiveRecord::Migration
  def change
    add_column :ios, :name, :string
  end
end
