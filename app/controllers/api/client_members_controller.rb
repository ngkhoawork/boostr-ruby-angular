class Api::ClientMembersController < ApplicationController
  respond_to :json

  def index
    render json: client.client_members
  end

  def create
    client_member = client.client_members.build(client_member_params)
    if client_member.save
      render json: client_member, status: :created
    else
      render json: { errors: client_member.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def client_member_params
    params.require(:client_member).permit(:role, :share, :user_id)
  end

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
  end
end
