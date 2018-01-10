class Api::SalesProcessesController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.sales_processes.is_active(params[:active])
  end

  def show
    render json: sales_process
  end

  def create
    sales_process = current_user.company.sales_processes.new(sales_process_params)

    if sales_process.save
      render json: sales_process
    else
      render json: { errors: sales_process.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if sales_process.update_attributes(sales_process_params)
      render json: sales_process
    else
      render json: { errors: sales_process.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if sales_process.destroy
      render nothing: true
    else
      render json: { errors: 'You can\'t delete default sales process' }, status: :unprocessable_entity
    end
  end

  private

  def sales_process
    @sales_process ||= current_user.company.sales_processes.find(params[:id])
  end

  def sales_process_params
    params.require(:sales_process).permit(:name, :active)
  end
end
