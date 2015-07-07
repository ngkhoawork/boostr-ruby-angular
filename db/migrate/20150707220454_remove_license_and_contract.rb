class RemoveLicenseAndContract < ActiveRecord::Migration
  def change
    drop_table :licenses
    drop_table :contracts
  end
end
