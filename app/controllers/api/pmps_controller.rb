class Api::PmpsController < ApplicationController
  respond_to :json
  def index
    render json: ActiveModel::ArraySerializer.new(
      pmps,
      each_serializer: Pmps::PmpListSerializer
    )
  end

  def show
    render json: pmp, serializer: Pmps::PmpDetailSerializer
  end

  def create
    pmp = company.pmps.new(pmp_params)

    if pmp.save
      render json: pmp.full_json, status: :created
    else
      render json: { errors: pmp.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if pmp.update_attributes(pmp_params)
      render json: pmp.full_json
    else
      render json: { errors: pmp.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.is_admin
      pmp.destroy

      render nothing: true
    else
      render json: { errors: 'You can\'t delete io' }, status: :unprocessable_entity
    end
  end

  private

  def pmp_params
    params.require(:io).permit(
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

  def pmps
    @_pmps ||= pmps_by_name
      .includes(:agency, :advertiser)
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
end
