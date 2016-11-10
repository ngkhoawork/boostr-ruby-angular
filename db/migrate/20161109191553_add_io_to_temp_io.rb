class AddIoToTempIo < ActiveRecord::Migration
  def change
    add_reference :temp_ios, :io, foreign_key: true
  end
end
