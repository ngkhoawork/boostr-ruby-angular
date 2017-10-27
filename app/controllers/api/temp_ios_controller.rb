class Api::TempIosController < ApplicationController
  respond_to :json
  def index
    render json: temp_ios
  end

  def update
    if temp_io.update_attributes(temp_io_params)
      render json: temp_io.as_json, status: :accepted
    else
      render json: { errors: temp_io.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def temp_io_params
    params.require(:temp_io).permit(
        :name,
        :company_id,
        :advertiser,
        :agency,
        :budget,
        :start_date,
        :end_date,
        :external_io_number,
        :io_id
    )
  end

  def temp_io
    @temp_io ||= current_user.company.temp_ios.where(id: params[:id]).first
  end

  def temp_ios
    company
      .temp_ios
      .includes(:currency)
      .by_start_date(params[:start_date], params[:end_date])
      .by_no_match(params[:filter])
      .by_names(params[:name])
      .limit(limit)
      .offset(offset)
  end

  def company
    current_user.company
  end
end
