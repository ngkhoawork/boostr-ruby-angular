class Api::ContentFeesController < ApplicationController
  respond_to :json

  def create
    content_fee = io.content_fees.new(content_fee_params)
    if content_fee.save
      render json: io.full_json
    else
      render json: { errors: content_fee.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if content_fee.update_attributes(content_fee_params)
      render json: io.full_json
    else
      render json: { errors: content_fee.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    content_fee.destroy
    io.update_total_budget
    render io.full_json
  end

  private

  def io
    @io ||= current_user.company.ios.find(params[:io_id])
  end

  def content_fee
    @content_fee ||= io.content_fees.find(params[:id])
  end

  def content_fee_params
    params.require(:content_fee).permit(
        :budget,
        :product_id,
        :io_id,
        {
            content_fee_product_budgets_attributes: [:id, :budget]
        }
    )
  end
end
