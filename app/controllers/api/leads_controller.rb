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
    lead.update(
      user_id: determine_assignee,
      reassigned_at: Time.now,
      status: nil,
      accepted_at: nil,
      rejected_at: nil
    )

    render nothing: true
  end

  def users
    render json: current_user.company.users.as_json(override: true, only: [:id], methods: [:name])
  end

  def map_with_client
    lead.update(client: client)

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

  def client
    Client.find(params[:client_id])
  end
end
