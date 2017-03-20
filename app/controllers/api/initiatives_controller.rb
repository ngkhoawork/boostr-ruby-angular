class Api::InitiativesController < ApplicationController
  respond_to :json

  def index
    respond_with company.initiatives, each_serializer: Initiatives::IndexSerializer
  end

  def create
    initiative = company.initiatives.new(initiative_params)

    if initiative.save
      render json: initiative, status: :created
    else
      render json: { errors: initiative.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if initiative.update_attributes(initiative_params)
      render json: initiative
    else
      render json: { errors: initiative.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if initiative.deals.blank?
      initiative.destroy
      render nothing: true
    else
      render json: { errors: 'You can\'t delete initiative which is linked to deal' }, status: :unprocessable_entity
    end
  end

  def smart_report
    respond_with open_or_closed_initiatives, each_serializer: Initiatives::SmartReportSerializer
  end

  def smart_report_deals
    render json: {
      open_deals: initiative_smart_report_serializer_for(initiative.deals.open),
      won_deals: initiative_smart_report_serializer_for(initiative.deals.won),
      lost_deals: initiative_smart_report_serializer_for(initiative.deals.lost)
    }
  end

  private

  def company
    @_company ||= current_user.company
  end

  def initiative
    @_initiative ||= company.initiatives.find(params[:id])
  end

  def open_or_closed_initiatives
    if params[:closed].present?
      company.initiatives.closed
    else
      company.initiatives.open
    end
  end

  def initiative_params
    params.require(:initiative).permit(:name, :goal, :status)
  end

  def initiative_smart_report_serializer_for(deals)
    ActiveModel::ArraySerializer.new(deals, each_serializer: Initiatives::SmartReportDealsSerializer)
  end
end
