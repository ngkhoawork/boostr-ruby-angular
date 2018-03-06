class RemoveTypeFromCost < ActiveRecord::Migration
  def change
    remove_column :costs, :type
  end
end
