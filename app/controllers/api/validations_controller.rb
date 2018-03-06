class Api::ValidationsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.validations.by_factor(params[:factor])
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

  def deal_base_fields
    render json: deal_base_fields_json
  end

  def billing_contact_fields
    render json: billing_contact_fields_json
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

  def billing_contact_fields_json
    company.validations.billing_contact_fields.preload(:criterion)
  end

  def account_base_fields_json
    company.validations.account_base_fields.preload(:criterion).group_by(&:object)
  end

  def deal_base_fields_json
    company.validations.deal_base_fields.preload(:criterion)
  end
end
