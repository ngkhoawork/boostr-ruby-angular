class ChangeProductMarginDefaultNull < ActiveRecord::Migration
  def change
    change_column_default :products, :margin, nil
    Product.where(margin: 100).update_all(margin: nil)
  end
end
