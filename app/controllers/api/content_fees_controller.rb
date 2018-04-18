class Api::ContentFeesController < ApplicationController
  respond_to :json

  def create
    converted_params = ConvertCurrency.call(io.exchange_rate, content_fee_params, io.exchange_rate_at_close)
    content_fee_obj = io.content_fees.new(converted_params)
    content_fee_obj.update_periods if params[:content_fee][:content_fee_product_budgets_attributes]
    if content_fee_obj.save
      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: content_fee_obj.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    converted_params = ConvertCurrency.call(io.exchange_rate, content_fee_params, io.exchange_rate_at_close)

    if content_fee.update_attributes(converted_params)
      content_fee.io.update_total_budget

      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: content_fee.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    content_fee.destroy
    io.update_total_budget
    render json: io, serializer: Ios::IoSerializer
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
        :budget_loc,
        :product_id,
        :io_id,
        {
            content_fee_product_budgets_attributes: [:id, :budget, :budget_loc]
        }
    )
  end
end
