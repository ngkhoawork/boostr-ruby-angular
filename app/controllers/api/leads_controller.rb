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

  def reject_from_email
    lead.update(status: Lead::REJECTED, rejected_at: Time.now)

    redirect_to "#{root_path}leads?relation=my&status=rejected"
  end

  def reassign
    lead.update(
      user_id: determine_assignee,
      reassigned_at: Time.now,
      status: Lead::ACCEPTED,
      accepted_at: Time.now,
      rejected_at: nil
    )

    LeadsMailer.new_leads_assignment(lead).deliver_now

    render nothing: true
  end

  def users
    render json: current_user.company.users.as_json(override: true, only: [:id], methods: [:name])
  end

  def map_with_client
    lead.update(client: client)
    map_contact_with_client

    render nothing: true
  end

  def show
    render json: Api::Leads::IndexSerializer.new(lead).serializable_hash
  end

  def import
    csv_import_worker_perform

    render json: { message: import_message }, status: :ok
  end

  private

  def lead
    Lead.find(params[:id])    
  end

  def filtered_leads
    LeadsQuery.new(params.merge(user: current_user)).perform
  end

  def determine_assignee
    params[:user_id] rescue lead.next_available_user
  end

  def client
    Client.find(params[:client_id])
  end

  def map_contact_with_client
    if lead.contact.present?
      client.client_contacts.create(contact: lead.contact, client: client)
    end
  end

  def import_message
    'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file '\
     'size)'
  end

  def csv_import_worker_perform
    LeadsImportWorker.perform_async(
      current_user.id,
      params[:file][:s3_file_path],
      params[:file][:original_filename]
    )
  end
end
