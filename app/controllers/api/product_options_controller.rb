class Api::ProductOptionsController < ApplicationController
  respond_to :json

  def index
    render json: product_options
  end

  def create
    new_product_option = product_options.new(product_option_params)
    if new_product_option.save
      render json: new_product_option, status: :created
    else
      render json: { errors: new_product_option.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if product_option.update_attributes(product_option_params)
      render json: product_option, status: :accepted
    else
      render json: { errors: product_option.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if product_option.destroy
      render nothing: true
    else
      render json: { errors: product_option.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def company
    @_company ||= current_user.company
  end

  def product_options
    @_product_options ||= company.product_options
  end

  def field
    @field ||= company.fields.where(id: params[:field_id]).first!
  end

  def product_option
    @_product_option ||= product_options.find(params[:id])
  end

  def product_option_params
    params.require(:product_option).permit(:name, :product_option_id).merge({ company_id: company.id })
  end
end
