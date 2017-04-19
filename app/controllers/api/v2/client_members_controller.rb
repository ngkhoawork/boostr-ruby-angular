class Api::V2::ClientMembersController < ApiController
  respond_to :json

  def index
    render json: client.client_members.order('share DESC')
  end

  def create
    client_member = client.client_members.build(client_member_params)
    if client_member.save
      render json: client_member, status: :created
    else
      render json: { errors: client_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if client_member.update_attributes(client_member_params)
      render json: client_member, status: :accepted
    else
      render json: { errors: client_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    client_member.destroy
    render json: true
  end

  private

  def client_member_params
    params.require(:client_member).permit(:role, :share, :user_id, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
  end

  def client_member
    @client_member ||= client.client_members.find(params[:id])
  end
end
