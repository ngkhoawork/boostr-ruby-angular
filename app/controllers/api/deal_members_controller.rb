class Api::DealMembersController < ApplicationController
  respond_to :json

  def index
    render json: deal.deal_members
  end

  def create
    deal_member = deal.deal_members.build(deal_member_params)
    if deal_member.save
      render json: deal_member, status: :created
    else
      render json: { errors: deal_member.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def deal_member_params
    params.require(:deal_member).permit(:role, :share, :user_id, :deal_id, :access)
  end

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end
end
