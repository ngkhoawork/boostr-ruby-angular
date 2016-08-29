class Api::OptionsController < ApplicationController
  respond_to :json

  def create
    if params[:field_id]
      @option = field.options.create(option_params)
    elsif params[:option_id]
      @option = parent_option.suboptions.create(option_params)
    end

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

  def parent_option
    Option.where(id: params[:option_id], company_id: company.id).first
  end

  def field
    @field ||= company.fields.where(id: params[:field_id]).first!
  end

  def option
    @option ||= Option.where(id: params[:id], company_id: company.id).first
  end

  def option_params
    params.require(:option).permit(:name, :position).merge({ company_id: company.id })
  end
end
