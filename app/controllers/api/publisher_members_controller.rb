class Api::PublisherMembersController < ApplicationController
  respond_to :json

  def create
    publisher_member = publisher.publisher_members.new(user_id: params[:id])

    if publisher_member.save
      render json: publisher_member, status: :created
    else
      render json: { errors: publisher_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if publisher_member.update(publisher_member_params)
      update_owner_field_in_publisher_scope if publisher_member.owner?

      render json: publisher_member
    else
      render json: { errors: publisher_member.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def publisher_member
    PublisherMember.find(params[:id])
  end

  def publisher
    current_user.company.publishers.find(params[:publisher_id])
  end

  def update_owner_field_in_publisher_scope
    publisher_member.publisher.publisher_members.where.not(id: publisher_member.id).update_all(owner: false)
  end

  def publisher_member_params
    params.require(:publisher_member).permit(:owner, :role_id)
  end
end
