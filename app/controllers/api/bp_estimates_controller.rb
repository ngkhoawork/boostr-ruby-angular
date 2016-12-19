class Api::BpEstimatesController < ApplicationController
  respond_to :json

  def create
    bp_estimate = bp.bp_estimates.new(bp_estimate_params)
    # bp_estimate.update_periods if params[:bp_estimate][:bp_estimate_budgets_attributes]
    if bp_estimate.save
      # bp.update_total_budget
      render json: bp
    else
      render json: { errors: bp_estimate.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if bp_estimate.update_attributes(bp_estimate_params)
      bp_estimate = bp.bp_estimates.find(params[:id])
      render json: bp_estimate.as_json({
         include: {
             bp_estimate_products: {
                 include: {
                     product: {}
                 }
             },
             client: {},
             user: {}
         },
         methods: [:client_name, :user_name]
      })
    else
      render json: { errors: bp_estimate.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    bp_estimate.destroy
    # bp.update_total_budget
    render json: bp
  end

  private

  def bp
    @bp ||= current_user.company.bps.find(params[:bp_id])
  end

  def bp_estimate
    @bp_estimate ||= bp.bp_estimates.find(params[:id])
  end

  def bp_estimate_params
    params.require(:bp_estimate).permit(
        :bp_id,
        :client_id,
        :user_id,
        :estimate_seller,
        :estimate_mgr,
        :objectives,
        :assumptions,
        {
            bp_estimate_products_attributes: [:id, :estimate_seller, :estimate_mgr]
        }
    )
  end
end
