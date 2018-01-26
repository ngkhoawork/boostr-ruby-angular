class Api::Dataexport::ProductsController < Api::Dataexport::BaseController
  private

  def collection
    current_user.company.products.includes(:product_family)
  end

  def serializer_class
    ::Dataexport::ProductSerializer
  end
end
