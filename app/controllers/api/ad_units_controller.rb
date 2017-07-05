class Api::AdUnitsController < ApplicationController
  before_action :set_ad_unit, only: [:show, :update, :destroy]

  # GET /api/ad_units
  # GET /api/ad_units.json
  def index
    render json: product.ad_units
  end

  # GET /api/ad_units/1
  # GET /api/ad_units/1.json
  def show
  end

  # POST /api/ad_units
  # POST /api/ad_units.json
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

  # PATCH/PUT /api/ad_units/1
  # PATCH/PUT /api/ad_units/1.json
  def update
    respond_to do |format|
      if @ad_unit.update(ad_unit_params)
        format.json { render json: @ad_unit, status: :ok }
      else
        format.json { render json: @ad_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/ad_units/1
  # DELETE /api/ad_units/1.json
  def destroy
    @ad_unit.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad_unit
      @ad_unit = product.ad_units.find(params[:id])
    end

    def product
      @product = Product.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_unit_params
      params.require(:ad_unit).permit(:product_id, :name)
    end
end
