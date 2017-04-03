class Api::V1::ActivityTypesController < ApiController
  def index
    render json: activity_types, each_serializer: Api::V1::ActivityTypeSerializer
  end

  private

  def activity_types
    ActivityType.where(company_id: current_user.company_id)
  end
end
