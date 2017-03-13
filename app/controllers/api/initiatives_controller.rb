class Api::InitiativesController < ApplicationController
  respond_to :json

  def index
    respond_with company.initiatives
  end

  def create
    initiative = company.initiatives.new(initiative_params)

    if initiative.save
      render json: initiative, status: :created
    else
      render json: { errors: initiative.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if initiative.update_attributes(initiative_params)
      render json: initiative
    else
      render json: { errors: initiative.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if initiative.deals.blank?
      initiative.destroy
      render nothing: true
    else
      render json: { errors: 'You can\'t delete initiative which is linked to deal' }, status: :unprocessable_entity
    end
  end

  private

  def company
    @_company ||= current_user.company
  end

  def initiative
    @_initiative ||= company.initiatives.find(params[:id])
  end

  def initiative_params
    params.require(:initiative).permit(:name, :goal, :status)
  end
end
