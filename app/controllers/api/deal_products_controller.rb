class Api::DealProductsController < ApplicationController
  respond_to :json, :csv

  before_filter :set_current_user, only: [:update, :create, :destroy]

  def index
    respond_to do |format|
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            send_data deal_product_csv, filename: "deal-products-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'DealProduct',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
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

  def deal_product_csv
    Csv::DealProductService.new(company, deal_products).perform
  end

  def deal_products
    @_deal_products ||=
      company.deal_products
             .includes(:product, :deal_product_cf, deal: [:advertiser, :agency, :stage])
             .order(:deal_id, :id)
  end

  def company
    current_user.company
  end

  def deal_product_params
    params.require(:deal_product).permit(
      :budget_loc,
      :product_id,
      :ssp_id,
      :is_guaranteed,
      :ssp_deal_id,
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
            :currency8,
            :currency9,
            :currency10,
            :currency_code1,
            :currency_code2,
            :currency_code3,
            :currency_code4,
            :currency_code5,
            :currency_code6,
            :currency_code7,
            :currency_code8,
            :currency_code9,
            :currency_code10,
            :text1,
            :text2,
            :text3,
            :text4,
            :text5,
            :text6,
            :text7,
            :text8,
            :text9,
            :text10,
            :note1,
            :note2,
            :note3,
            :note4,
            :note5,
            :note6,
            :note7,
            :note8,
            :note9,
            :note10,
            :datetime1,
            :datetime2,
            :datetime3,
            :datetime4,
            :datetime5,
            :datetime6,
            :datetime7,
            :datetime8,
            :datetime9,
            :datetime10,
            :number1,
            :number2,
            :number3,
            :number4,
            :number5,
            :number6,
            :number7,
            :number8,
            :number9,
            :number10,
            :integer1,
            :integer2,
            :integer3,
            :integer4,
            :integer5,
            :integer6,
            :integer7,
            :integer8,
            :integer9,
            :integer10,
            :boolean1,
            :boolean2,
            :boolean3,
            :boolean4,
            :boolean5,
            :boolean6,
            :boolean7,
            :boolean8,
            :boolean9,
            :boolean10,
            :percentage1,
            :percentage2,
            :percentage3,
            :percentage4,
            :percentage5,
            :percentage6,
            :percentage7,
            :percentage8,
            :percentage9,
            :percentage10,
            :dropdown1,
            :dropdown2,
            :dropdown3,
            :dropdown4,
            :dropdown5,
            :dropdown6,
            :dropdown7,
            :dropdown8,
            :dropdown9,
            :dropdown10,
            :sum1,
            :sum2,
            :sum3,
            :sum4,
            :sum5,
            :sum6,
            :sum7,
            :sum8,
            :sum9,
            :sum10,
            :number_4_dec1,
            :number_4_dec2,
            :number_4_dec3,
            :number_4_dec4,
            :number_4_dec5,
            :number_4_dec6,
            :number_4_dec7,
            :number_4_dec8,
            :number_4_dec9,
            :number_4_dec10
        ]
      }
    )
  end
end
