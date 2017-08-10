class Api::AdUnitsController < ApplicationController
  before_action :set_ad_unit, only: [:show, :update, :destroy]

  def index
    render json: product.ad_units
  end

  def create
    @ad_unit = product.ad_units.new(ad_unit_params)

    respond_to do |format|
      if @ad_unit.save
        format.json { render json: @ad_unit, status: :created }
      else
        format.json { render json: @ad_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ad_unit.update(ad_unit_params)
        format.json { render json: @ad_unit, status: :ok }
      else
        format.json { render json: @ad_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ad_unit.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_ad_unit
    @ad_unit = product.ad_units.find(params[:id])
  end

  def product
    @product = Product.find(params[:product_id])
  end

  def ad_unit_params
    params.require(:ad_unit).permit(:product_id, :name)
  end
end
