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

  def no_match_advertisers
    params.merge!(without_advertisers: true)
    render json: pmps_serializer
  end

  def assign_advertiser
    pmp.assign_advertiser!(client)
    render json: pmp, serializer: Pmps::PmpDetailSerializer
  end

  def bulk_assign_advertiser
    opts = {
      ssp_advertiser_id: params[:ssp_advertiser_id],
      client: client,
      company: current_user.company
    }
    render json: Pmp::AssignAdvertiser.new(opts).bulk_assign
  end

  private

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

  def filter_params
    params.permit(
      :name,
      :start_date,
      :end_date,
      :without_advertisers
    ).merge(company_id: company.id)
  end

  def pmps_serializer
    ActiveModel::ArraySerializer.new(
      by_pages(pmps),
      each_serializer: Pmps::PmpListSerializer
    )
  end

  def client
    @_client ||= company.clients.find(params[:client_id])
  end

  def pmps
    PmpsQuery.new(filter_params).perform
  end

  def pmp
    @_pmp ||= company.pmps.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end
end
