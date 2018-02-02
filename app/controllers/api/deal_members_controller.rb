class Api::DealMembersController < ApplicationController
  respond_to :json

  before_filter :set_current_user, except: :index

  def index
    render json: deal.deal_members
  end

  def create
    deal_member = deal.deal_members.new(deal_member_params)
    if deal_member.save
      render deal
    else
      render json: { errors: deal_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if deal_member.update_attributes(deal_member_params)
      render deal
    else
      render json: { errors: deal_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal_member.destroy

    render deal
  end

  private

  def deal_member_params
    params.require(:deal_member).permit(:share, :user_id, :deal_id, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def deal_member
    @deal_member ||= deal.deal_members.find(params[:id])
  end
end
