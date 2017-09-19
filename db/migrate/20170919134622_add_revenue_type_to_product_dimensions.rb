class AddRevenueTypeToProductDimensions < ActiveRecord::Migration
  def change
    add_column :product_dimensions, :revenue_type, :string
  end
end
