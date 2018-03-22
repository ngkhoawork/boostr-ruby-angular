class ChangeProductMarginDefault < ActiveRecord::Migration
  def change
    change_column_default :products, :margin, 100
    Product.where(margin: nil).update_all(margin: 100)
  end
end
