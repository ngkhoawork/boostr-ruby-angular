class Api::LeadsController < ApplicationController
  respond_to :json

  def index
    render json: filtered_leads, each_serializer: Api::Leads::IndexSerializer
  end

  def accept
    lead.update(status: Lead::ACCEPTED, accepted_at: Time.now)

    render nothing: true
  end

  def reject
    lead.update(status: Lead::REJECTED, rejected_at: Time.now)

    render nothing: true
  end

  def reassign
    lead.update(user_id: determine_assignee, reassigned_at: Time.now)

    render nothing: true
  end

  private

  def lead
    Lead.find(params[:id])    
  end

  def filtered_leads
    LeadsQuery.new(params.merge(user: current_user)).perform
  end

  def determine_assignee
    params[:user_id] rescue next_assignee
  end
end
