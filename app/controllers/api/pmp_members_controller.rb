class Api::PmpMembersController < ApplicationController
  respond_to :json

  def create
    pmp_member = pmp.pmp_members.build(pmp_member_params)
    if pmp_member.save
      render json: pmp_member, serializer: Pmps::PmpMemberSerializer
    else
      render json: { errors: pmp_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if pmp_member.update_attributes(pmp_member_params)
      render json: pmp_member, serializer: Pmps::PmpMemberSerializer
    else
      render json: { errors: pmp_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    pmp_member.destroy
    render nothing: true
  end

  private

  def pmp_member_params
    params.require(:pmp_member).permit(
      :share,
      :user_id,
      :from_date,
      :to_date
    )
  end

  def company
    @_company ||= current_user.company
  end
  def pmp
    @_pmp ||= company.pmps.find(params[:pmp_id])
  end

  def pmp_member
    @_pmp_member ||= pmp.pmp_members.find(params[:id])
  end
end
