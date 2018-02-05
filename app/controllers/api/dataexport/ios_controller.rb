class Api::Dataexport::IosController < Api::Dataexport::BaseController
  private

  def collection
    current_user.company.ios.includes(:advertiser, :agency)
  end

  def serializer_class
    ::Dataexport::IoSerializer
  end
end
