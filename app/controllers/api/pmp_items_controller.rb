class Api::PmpItemsController < ApplicationController
  respond_to :json

  def create
    pmp_item = pmp.pmp_items.build(pmp_item_params)
    if pmp_item.save
      render json: pmp_item, serializer: Pmps::PmpItemSerializer
    else
      render json: { errors: pmp_item.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if pmp_item.update_attributes(pmp_item_params)
      render json: pmp, serializer: Pmps::PmpDetailSerializer
    else
      render json: { errors: pmp_item.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    pmp_item.destroy
    render nothing: true
  end

  private

  def pmp_item_params
    params.require(:pmp_item).permit(
      :ssp_id,
      :ssp_deal_id,
      :budget_loc,
      :pmp_type,
      :product_id
    )
  end

  def company
    @_company ||= current_user.company
  end
  
  def pmp
    @_pmp ||= company.pmps.find(params[:pmp_id])
  end

  def pmp_item
    @_pmp_item ||= pmp.pmp_items.find(params[:id])
  end
end
