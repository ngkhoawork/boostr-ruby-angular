class Api::IosController < ApplicationController
  respond_to :json

  def index
    render json: ios
  end

  def show
    render json: io.full_json
  end

  def create
    io = company.ios.new(io_params)
    if io.deal_id
      io.io_number = io.deal_id
    elsif io.external_io_number
      io.io_number = io.external_io_number
    end
    if io.save
      render json: io.full_json, status: :created
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if io.update_attributes(io_params)
      render json: io.full_json
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def io_params
    params.require(:io).permit(:name, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :io_number, :external_io_number, :deal_id)
  end

  def ios
    if params[:page] && params[:page].to_i > 0
      offset = (params[:page].to_i - 1) * 10
      if params[:name]
        company.ios.where("name ilike ?", "%#{params[:name]}%").limit(10).offset(offset)
      else
        company.ios.limit(10).offset(offset)
      end
    else
      if params[:name]
        company.ios.where("name ilike ?", "%#{params[:name]}%")
      else
        company.ios.order("name asc, id asc")
      end
    end
  end


  def io
    @io ||= ios.find(params[:id])
  end

  def company
    current_user.company
  end
end
