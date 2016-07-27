class Api::SalesExecutionDashboardController < ApplicationController
  respond_to :json

  def index
    deal_member_ids = DealMember.where("user_id in (?)", params[:member_ids]).select(:deal_id).collect {|deal_member| deal_member.deal_id}
    top_deals = Deal.where('deals.id in (?)', deal_member_ids).open.order("coalesce(budget, 0) desc").limit(10)

    start_date = Time.now.utc.beginning_of_week - 7.days
    end_date = Time.now.utc.beginning_of_week - 1.seconds
    pipeline_won = Deal.where('deals.id in (?)', deal_member_ids).closed.closed_at(start_date, end_date).at_percent(100).sum(:budget)
    pipeline_lost = Deal.where('deals.id in (?)', deal_member_ids).closed.closed_at(start_date, end_date).at_percent(0).sum(:budget)
    pipeline_added = Deal.where('deals.id in (?)', deal_member_ids).stated_at(start_date, end_date).sum(:budget)

    week_pipeline_data = [
        {name: 'Added', value: pipeline_added, color:'#f8cbad'},
        {name: 'Won', value: pipeline_won, color:'#a9d18e'},
        {name: 'Lost', value: pipeline_lost, color:'#bfbfbf'}
    ]

    render json: [{top_deals: top_deals, week_pipeline_data: week_pipeline_data}]
  end

  def team
    @team ||= current_user.company.teams.where(id: params[:team_id]).first
  end

  def member
    @user ||= current_user.company.users.where(id: params[:member_id]).first
  end
end
