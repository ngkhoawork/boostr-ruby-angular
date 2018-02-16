class Api::Dataexport::DealsController < Api::Dataexport::BaseController
  private

  def collection
    current_user.company.deals.includes(:advertiser, :stage, :agency, :deal_custom_field)
  end

  def serializer_class
    ::Dataexport::DealSerializer
  end
end
