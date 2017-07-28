class Api::ValidationsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.validations
  end

  def update
    if validation.update_attributes(validation_params)
      render json: validation, status: :accepted
    else
      render json: { errors: validation.errors.messages }, status: :unprocessable_entity
    end
  end

  def account_base_fields
    render json: account_base_fields_json
  end

  def validation_params
    params.require(:validation).permit(
      {
        criterion_attributes: [:id, :value]
      }
    )
  end

  private

  def validation
    @validation ||= company.validations.find(params[:id])
  end

  def company
    @company ||= current_user.company
  end

  def account_base_fields_json
    current_user.company.validations.account_base_fields.preload(:criterion).group_by(&:object)
  end
end
