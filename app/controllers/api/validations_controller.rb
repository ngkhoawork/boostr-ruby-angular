class Api::ValidationsController < ApplicationController
  respond_to :json

  def index
    render json: validations.by_factor(params[:factor])
  end

  def update
    if validation.update_attributes(validation_params)
      render json: validation, status: :accepted
    else
      render json: { errors: validation.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    if build_validation.save
      render json: build_validation, status: :created
    else
      render json: { errors: build_validation.errors.messages }, status: :unprocessable_entity
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

  def destroy
    validation.destroy
    render nothing: true
  end

  private

  def validation_params
    params.require(:validation).permit(
      :object,
      :factor,
      :value_type,
      criterion_attributes: [:id, :value, :value_object_id, :value_object_type, :value_type]
    )
  end

  def core_validation_params
    validation_params.except(:criterion_attributes)
  end

  def criterion_params
    validation_params[:criterion_attributes]
  end

  def build_validation
    @_build_validation ||= validations.find_or_initialize_by(core_validation_params).tap do |validation|
      validation.criterion_attributes = criterion_params
    end
  end

  def validation
    @_validation ||= validations.find(params[:id])
  end

  def validations
    @_validations ||= company.validations
  end

  def company
    @_company ||= current_user.company
  end

  def billing_contact_fields_json
    validations.billing_contact_fields.preload(:criterion)
  end

  def account_base_fields_json
    validations.account_base_fields.preload(:criterion).group_by(&:object)
  end

  def deal_base_fields_json
    validations.deal_base_fields.preload(:criterion)
  end
end
