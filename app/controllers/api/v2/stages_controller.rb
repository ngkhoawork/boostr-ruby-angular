class Api::V2::StagesController < ApiController
  respond_to :json

  def index
    render json: filtered_stages, each_serializer: StageSerializer
  end

  def show
    render json: stage
  end

  def create
    stage = current_user.company.stages.create(stage_params)

    if stage.persisted?
      render json: stage
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if stage.update_attributes(stage_params)
      render json: stage
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def stage
    @stage ||= current_user.company.stages.find(params[:id])
  end

  def stage_params
    params.require(:stage).permit(:name, :probability, :position, :open, :active, :avg_day, :yellow_threshold, :red_threshold)
  end

  def filtered_stages
    StagesQuery.new(filter_params).perform
  end

  def filter_params
    params.permit(:team_id, :sales_process_id, :current_team, :active, :open)
        .merge(current_user: current_user, company_id: current_user.company_id)
  end
end
