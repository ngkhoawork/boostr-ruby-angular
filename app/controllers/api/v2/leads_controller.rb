class Api::V2::LeadsController < ApiController
  skip_before_action :authenticate_token_user

  respond_to :json

  def create
    lead = Lead.new(lead_params)

    if lead.save
      LeadsMailer.new_leads_assignment(lead).deliver_now

      render json: { status: 'Lead was successfully created' }, status: :created
    else
      render json: { errors: lead.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params
      .require(:lead)
      .permit(:first_name, :last_name, :title, :email, :company_name, :country, :state, :budget, :notes, :company_id)
  end
end
