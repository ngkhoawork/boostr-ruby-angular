class Api::SpendAgreementDealsController < ApplicationController
  respond_to :json

  def index
    render json: spend_agreement_deals.includes(deal: [:stage]), each_serializer: Api::SpendAgreements::DealsSerializer
  end

  def create
    spend_agreement_deal = spend_agreement_deals.build(spend_agreement_deal_params)

    if spend_agreement_deal.save
      render json: spend_agreement_deal, status: :created
    else
      render json: { errors: spend_agreement_deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    spend_agreement_deal.destroy
    render json: true
  end

  def available_to_match
    render json: available_to_match_deals
  end

  private

  def spend_agreement_deal_params
    params.require(:spend_agreement_deal).permit(:id, :deal_id, :spend_agreement_id)
  end

  def company
    current_user.company
  end

  def spend_agreement
    company.spend_agreements.find(params[:spend_agreement_id])
  end

  def spend_agreement_deal
    spend_agreement_deals.find(params[:id])
  end

  def spend_agreement_deals
    spend_agreement
      .spend_agreement_deals
      .exclude_ids(params[:exclude_ids])
  end

  def available_to_match_deals
    deal_ids = SpendAgreementTrackingService.new(spend_agreement: spend_agreement).untracked_deals
    company.deals.where(id: deal_ids).pluck_to_hash(:id, :name)
  end
end
