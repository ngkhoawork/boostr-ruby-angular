class Api::AdUnitsController < ApplicationController
  before_action :set_ad_unit, only: [:show, :update, :destroy]

  # GET /api/ad_units
  # GET /api/ad_units.json
  def index
    @ad_units = AdUnit.all
  end

  # GET /api/ad_units/1
  # GET /api/ad_units/1.json
  def show
  end

  # GET /api/ad_units/new
  def new
    @ad_unit = AdUnit.new
  end

  # POST /api/ad_units
  # POST /api/ad_units.json
  def create
    @ad_unit = AdUnit.new(ad_unit_params)

    respond_to do |format|
      if @ad_unit.save
        format.json { render :show, status: :created, location: @ad_unit }
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
        format.json { render :show, status: :ok, location: @ad_unit }
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
      @ad_unit = AdUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_unit_params
      params[:ad_unit]
    end
end
