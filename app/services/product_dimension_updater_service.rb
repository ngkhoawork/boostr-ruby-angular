class ProductDimensionUpdaterService < BaseService
  def perform
    Upsert.batch(connection, :product_dimensions) do |upsert|
      products.each do |product|
        upsert.row(product.attributes)
      end
    end
  end

  def products
    @_products ||= Product.select(:id, :name, :revenue_type, :company_id, :created_at, :updated_at)
  end

  def connection
    ActiveRecord::Base.retrieve_connection
  end
end