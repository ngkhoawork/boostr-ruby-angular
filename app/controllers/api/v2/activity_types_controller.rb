class Api::V2::ActivityTypesController < ApiController
  def index
    render json: activity_types, each_serializer: Api::V2::ActivityTypeSerializer
  end

  private

  def activity_types
    ActivityType
      .where(company_id: current_user.company_id)
      .active
      .ordered_by_position
  end
end
