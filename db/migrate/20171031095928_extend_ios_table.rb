class ExtendIosTable < ActiveRecord::Migration
  def up
    change_column :ios, :external_io_number, :bigint
    change_column :temp_ios, :external_io_number, :bigint
  end

  def down
    change_column :ios, :external_io_number, :integer
    change_column :temp_ios, :external_io_number, :integer
  end
end
