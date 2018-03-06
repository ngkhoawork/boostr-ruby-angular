class Api::ValidationsController < ApplicationController
  respond_to :json

  def index
    render json: company.validations.by_factor(params[:factor])
  end

  def update
    if validation.update_attributes(validation_params)
      render json: validation, status: :accepted
    else
      render json: { errors: validation.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    validation = company.validations.find_or_initialize_by(validation_params.except(:criterion_attributes))

    if validation.save && validation.criterion.update_attributes(validation_params[:criterion_attributes])
      render json: validation, status: :created
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
      :object,
      :factor,
      :value_type,
      criterion_attributes: [:id, :value, :value_object_id, :value_object_type]
    )
  end

  def destroy
    validation.destroy
    render nothing: true
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
