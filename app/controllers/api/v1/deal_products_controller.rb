class Api::V1::DealProductsController < ApiController
  respond_to :json

  before_filter :set_current_user, only: [:update, :create, :destroy]

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DealProduct.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    else
      exchange_rate = deal.exchange_rate
      converted_params = ConvertCurrency.call(exchange_rate, deal_product_params)
      deal_product = deal.deal_products.new(converted_params)
      deal_product.update_periods if params[:deal_product][:deal_product_budgets_attributes]
      if deal_product.save
        DealTotalBudgetUpdaterService.perform(deal)

        render deal
      else
        render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    exchange_rate = deal.exchange_rate
    converted_params = ConvertCurrency.call(exchange_rate, deal_product_params)
    if deal_product.update_attributes(converted_params)
      DealTotalBudgetUpdaterService.perform(deal)

      render deal
    else
      render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless deal.valid?
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    else
      deal_product.destroy
      DealTotalBudgetUpdaterService.perform(deal)

      render deal
    end
  end

  private

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def deal_product
    @deal_product ||= deal.deal_products.find(params[:id])
  end

  def deal_product_params
    params.require(:deal_product).permit(
      :budget_loc,
      :product_id,
      {
        deal_product_budgets_attributes: [:id, :budget_loc]
      }
    )
  end
end
