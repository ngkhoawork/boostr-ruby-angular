class Api::Dataexport::DealProductsController < Api::Dataexport::BaseController
  private

  def collection
    DealProduct.where(deal_id: current_user.company.deals.pluck(:id))
  end

  def serializer_class
    ::Dataexport::DealProductSerializer
  end
end
