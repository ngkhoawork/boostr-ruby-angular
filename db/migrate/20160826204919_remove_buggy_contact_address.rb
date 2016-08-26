class RemoveBuggyContactAddress < ActiveRecord::Migration
  def change
    addresses = Address.where("addressable_id is null")
    addresses.destroy_all
  end
end
