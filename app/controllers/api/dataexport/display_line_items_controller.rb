class Api::Dataexport::DisplayLineItemsController < Api::Dataexport::BaseController
  private

  def collection
    DisplayLineItem.where(io_id: current_user.company.ios.pluck(:id))
  end

  def serializer_class
    ::Dataexport::DisplayLineItemSerializer
  end
end
