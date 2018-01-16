class Api::Dataexport::StagesController < Api::Dataexport::BaseController
  private

  def collection
    current_user.company.stages
  end

  def serializer_class
    ::Dataexport::StageSerializer
  end
end
