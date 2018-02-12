class Api::CostsController < ApplicationController
  respond_to :json

  def create
    exchange_rate = io.exchange_rate
    converted_params = ConvertCurrency.call(exchange_rate, cost_params)
    converted_params[:is_estimated] = false
    cost_obj = io.costs.new(converted_params)
    cost_obj.update_periods if params[:cost][:cost_monthly_amounts_attributes]
    if cost_obj.save
      render json: io.full_json
    else
      render json: { errors: cost_obj.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    exchange_rate = io.exchange_rate
    converted_params = ConvertCurrency.call(exchange_rate, cost_params)
    if cost.update_attributes(converted_params)
      cost.io.update_total_budget

      render json: io.full_json
    else
      render json: { errors: cost.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    cost.destroy
    io.update_total_budget
    render json: io.full_json
  end

  private

  def company
    @_company ||= current_user.company
  end

  def io
    @_io ||= company.ios.find(params[:io_id])
  end

  def cost
    @_cost ||= io.costs.find(params[:id])
  end

  def cost_params
    params.require(:cost).permit(
        :budget,
        :budget_loc,
        :product_id,
        :type,
        :io_id,
        {
          values_attributes: [
            :id,
            :field_id,
            :option_id,
            :value
          ],
          cost_monthly_amounts_attributes: [
            :id,
            :budget,
            :budget_loc
          ]
        }
    )
  end
end
