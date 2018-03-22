class Api::IoMembersController < ApplicationController
  respond_to :json

  def index
    render json: io.io_members
  end

  def create
    io_member = io.io_members.build(io_member_params)
    if io_member.save
      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: io_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if io_member.update_attributes(io_member_params)
      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: io_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    io_member.destroy
    render json: io, serializer: Ios::IoSerializer
  end

  private

  def io_member_params
    params.require(:io_member).permit(:share, :user_id, :io_id, :from_date, :to_date
                                      # { values_attributes: [:id, :field_id, :option_id, :value]}
    )
  end

  def io
    @io ||= current_user.company.ios.find(params[:io_id])
  end

  def io_member
    @io_member ||= io.io_members.find(params[:id])
  end
end
