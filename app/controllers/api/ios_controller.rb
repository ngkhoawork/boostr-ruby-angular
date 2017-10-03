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

  def update_influencer_budget
    if io
      errors = []
      io.influencer_content_fees.each do |influencer_content_fee|
        if influencer_content_fee.effect_date < io.start_date || influencer_content_fee.effect_date > io.end_date
          errors << "Asset date of influencer #{influencer_content_fee.influencer.name} is out of IO's date range."
        end
      end
      if errors.count > 0
        render json: { errors: errors }, status: :unprocessable_entity
        return
      end
      io.update_influencer_budget
      io.reload
      render json: io.full_json
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.is_admin
      io.destroy

      render nothing: true
    else
      render json: { errors: 'You can\'t delete io' }, status: :unprocessable_entity
    end
  end

  private

  def io_params
    params.require(:io).permit(
      :name,
      :budget,
      :budget_loc,
      :curr_cd,
      :start_date,
      :end_date,
      :advertiser_id,
      :agency_id,
      :io_number,
      :external_io_number,
      :deal_id
    )
  end

  def ios
    if params[:agency_id]
      company.ios.where("agency_id = ?", params[:agency_id])
    elsif params[:advertiser_id]
      company.ios.where("advertiser_id = ?", params[:advertiser_id])
    elsif params[:page] && params[:page].to_i > 0
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
    @io ||= company.ios.find(params[:id])
  end

  def company
    current_user.company
  end
end
