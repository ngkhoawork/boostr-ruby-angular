class Api::V2::DisplayLineItemsController < ApiController
  respond_to :json

  # TEMP, DELETE
  def show
    dli = current_user.company.display_line_items.first
    render json: dli
  end
  # TEMP, DELETE

  def create
    if line_item.valid?
      line_item.perform
      render json: line_item, status: :created
    else
      render json: { errors: line_item.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def line_item
    line_item = build_line_item(line_item_params)
  end

  def build_line_item(params)
    params[:company_id] = current_user.company.id
    DisplayLineItemCsv.new(params)
  end

  def line_item_params
    params.require(:display_line_item).permit(
      :external_io_number,
      :line_number,
      :ad_server,
      :start_date,
      :end_date,
      :product_name,
      :quantity,
      :price,
      :pricing_type,
      :budget,
      :budget_delivered,
      :quantity_delivered,
      :quantity_delivered_3p
    )
  end
end
