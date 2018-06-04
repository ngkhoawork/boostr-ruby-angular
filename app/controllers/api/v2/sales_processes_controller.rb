class Api::V2::SalesProcessesController < ApiController
  respond_to :json

  def index
    render json: company.sales_processes.by_active(params[:active])
  end

  def show
    render json: sales_process
  end

  def create
    sales_process = company.sales_processes.new(sales_process_params)

    if sales_process.save
      render json: sales_process, status: :created
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

  private

  def company
    current_user.company
  end

  def sales_process
    @_sales_process ||= company.sales_processes.find(params[:id])
  end

  def sales_process_params
    params.require(:sales_process).permit(:name, :active)
  end
end
