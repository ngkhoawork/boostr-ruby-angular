class Api::DealProductsController < ApplicationController
  respond_to :json

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
        deal.update_total_budget
        render deal
      else
        render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    exchange_rate = deal.exchange_rate
    converted_params = ConvertCurrency.call(exchange_rate, deal_product_params)
    puts "============="
    puts converted_params
    if deal_product.update_attributes(converted_params)
      deal.update_total_budget
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
      deal.update_total_budget
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
        deal_product_budgets_attributes: [:id, :budget_loc],
        deal_product_cf_attributes: [
            :id,
            :company_id,
            :deal_id,
            :currency1,
            :currency2,
            :currency3,
            :currency4,
            :currency5,
            :currency6,
            :currency7,
            :currency_code1,
            :currency_code2,
            :currency_code3,
            :currency_code4,
            :currency_code5,
            :currency_code6,
            :currency_code7,
            :text1,
            :text2,
            :text3,
            :text4,
            :text5,
            :note1,
            :note2,
            :datetime1,
            :datetime2,
            :datetime3,
            :datetime4,
            :datetime5,
            :datetime6,
            :datetime7,
            :number1,
            :number2,
            :number3,
            :number4,
            :number5,
            :number6,
            :number7,
            :integer1,
            :integer2,
            :integer3,
            :integer4,
            :integer5,
            :integer6,
            :integer7,
            :boolean1,
            :boolean2,
            :boolean3,
            :percentage1,
            :percentage2,
            :percentage3,
            :percentage4,
            :percentage5,
            :dropdown1,
            :dropdown2,
            :dropdown3,
            :dropdown4,
            :dropdown5,
            :dropdown6,
            :dropdown7,
            :sum1,
            :sum2,
            :sum3,
            :sum4,
            :sum5,
            :sum6,
            :sum7,
            :number_4_dec1,
            :number_4_dec2,
            :number_4_dec3,
            :number_4_dec4,
            :number_4_dec5,
            :number_4_dec6,
            :number_4_dec7
        ]
      }
    )
  end
end
