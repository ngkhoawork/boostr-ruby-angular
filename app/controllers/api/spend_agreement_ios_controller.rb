class Api::SpendAgreementIosController < ApplicationController
  respond_to :json

  def index
    render json: ios,
           each_serializer: Api::SpendAgreements::IoSerializer,
           agreement_start_date: spend_agreement.start_date,
           agreement_end_date: spend_agreement.end_date
  end

  private

  def spend_agreement_io_params
    params.require(:spend_agreement_io).permit(:id, :io_id, :spend_agreement_id)
  end

  def company
    current_user.company
  end

  def spend_agreement
    @_spend_agreement ||= company.spend_agreements.find(params[:spend_agreement_id])
  end

  def ios
    spend_agreement.ios.includes(:advertiser)
  end
end
