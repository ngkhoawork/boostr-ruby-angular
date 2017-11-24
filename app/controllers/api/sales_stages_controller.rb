class Api::SalesStagesController < ApplicationController
  respond_to :json

  def index
    render json: company.sales_stages
  end

  def create
    sales_stage = company.sales_stages.new(sales_stage_params)

    if sales_stage.save
      render json: sales_stage, status: :created
    else
      render json: { errors: sales_stage.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if sales_stage.update_attributes(sales_stage_params)
      render json: sales_stage
    else
      render json: { errors: sales_stage.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_positions
    positions = params[:sales_stages_position]
    sales_stages = company.sales_stages.where(id: positions.keys)

    sales_stages.each do |sales_stage|
      sales_stage.update(position: positions[sales_stage.id.to_s])
    end

    render json: sales_stages
  end

  private

  def company
    current_user.company
  end

  def sales_stage
    @_sales_stage ||= company.sales_stages.find(params[:id])
  end

  def sales_stage_params
    params.require(:sales_stage).permit(:name, :probability, :position, :open, :active)
  end
end
