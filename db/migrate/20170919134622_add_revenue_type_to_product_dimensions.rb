class AddRevenueTypeToProductDimensions < ActiveRecord::Migration
  def change
    unless column_exists? :product_dimensions, :revenue_type
      add_column :product_dimensions, :revenue_type, :string
    end
  end
end
