class GenerateProductDimension < ActiveRecord::Migration
  def change
  	ProductDimension.destroy_all
  	Product.all.each do |product|
  		product_dimension_param = {
  			id: product.id,
  			name: product.name,
  			company_id: product.company.present? ? product.company_id : nil
  		}
  		product_dimension = ProductDimension.new(product_dimension_param)
  		product_dimension.save
  	end
  end
end
