class Api::ActivityTypesController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: activity_types
      }
    end
  end

  private

  def activity_params
    params.require(:activity_type).permit(:name, :action, :icon)
  end

  def activity_type
    @activity_type ||= company.activity_types.find(params[:id])
  end

  def activity_types
    current_user.company.activity_types
  end

  def company
    @company ||= current_user.company
  end

end
