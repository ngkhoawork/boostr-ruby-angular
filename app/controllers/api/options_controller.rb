class Api::OptionsController < ApplicationController
  respond_to :json

  def create
    @option = field.options.create(option_params)
    if option.persisted?
      render json: option, status: :created
    else
      render json: { errors: option.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if option.update_attributes(option_params)
      render json: option, status: :accepted
    else
      render json: { errors: option.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    option.destroy
    render json: option
  end

  private

  def company
    @company ||= current_user.company
  end

  def field
    @field ||= company.fields.where(id: params[:field_id]).first!
  end

  def option
    @option ||= field.options.where(id: params[:id]).first!
  end

  def option_params
    params.require(:option).permit(:name, :position).merge({ company_id: company.id })
  end
end
