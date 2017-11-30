class Api::PmpsController < ApplicationController
  respond_to :json

  def index
    render json: pmps_serializer
  end

  def show
    render json: pmp, serializer: Pmps::PmpDetailSerializer
  end

  def create
    pmp = company.pmps.new(pmp_params)

    if pmp.save
      render json: pmp, serializer: Pmps::PmpDetailSerializer, status: :created
    else
      render json: { errors: pmp.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if pmp.update_attributes(pmp_params)
      render json: pmp, serializer: Pmps::PmpDetailSerializer
    else
      render json: { errors: pmp.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.is_admin
      pmp.destroy
      render nothing: true
    else
      render json: { error: 'You can\'t delete pmp' }, status: :unprocessable_entity
    end
  end

  private

  def pmps_serializer
    ActiveModel::ArraySerializer.new(
      pmps,
      each_serializer: Pmps::PmpListSerializer
    )
  end

  def pmp_params
    params.require(:pmp).permit(
      :name,
      :budget,
      :budget_loc,
      :curr_cd,
      :start_date,
      :end_date,
      :advertiser_id,
      :agency_id,
      :deal_id
    )
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def pmps
    @_pmps ||= pmps_by_name
      .union(pmps_by_agency)
      .union(pmps_by_advertiser)
      .includes(:agency, :advertiser)
      .by_start_date(params[:start_date], params[:end_date])
      .limit(limit)
      .offset(offset)
  end

  def pmp
    @_pmp ||= company.pmps.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end

  def company_pmps
    @_company_pmps ||= company.pmps
  end

  def pmps_by_name
    @_pmps_by_name ||= company_pmps.by_name(params[:name])
  end

  def pmps_by_agency
    @_pmps_by_agency ||= company_pmps.by_agency_name(params[:name])
  end

  def pmps_by_advertiser
    @_pmps_by_advertiser ||= company_pmps.by_advertiser_name(params[:name])
  end
end
