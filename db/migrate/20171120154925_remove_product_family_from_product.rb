class RemoveProductFamilyFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :family, :string
  end
end
