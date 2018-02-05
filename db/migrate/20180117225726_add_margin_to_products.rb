class AddMarginToProducts < ActiveRecord::Migration
  def change
    add_column :products, :margin, :integer
  end
end
