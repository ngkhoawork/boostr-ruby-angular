class Api::SpendAgreementTeamMembersController < ApplicationController
  respond_to :json

  def index
    render json: spend_agreement_team_members,
      each_serializer: Api::SpendAgreements::TeamMemberSerializer,
      role: role_field_id
  end

  def create
    spend_agreement_team_member = spend_agreement_team_members.build(spend_agreement_team_member_params)

    if spend_agreement_team_member.save
      render json: spend_agreement_team_member,
             serializer: Api::SpendAgreements::TeamMemberSerializer,
             role: role_field_id,
             status: :created
    else
      render json: { errors: spend_agreement_team_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if spend_agreement_team_member.update_attributes(spend_agreement_team_member_params)
      render json: spend_agreement_team_member,
             serializer: Api::SpendAgreements::TeamMemberSerializer,
             role: role_field_id,
             status: :accepted
    else
      render json: { errors: spend_agreement_team_member.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    spend_agreement_team_member.destroy
    render json: true
  end

  private

  def spend_agreement_team_member_params
    params.require(:spend_agreement_team_member).permit(:id, :user_id, :spend_agreement_id, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def company
    current_user.company
  end

  def spend_agreement
    company.spend_agreements.find(params[:spend_agreement_id])
  end

  def spend_agreement_team_member
    spend_agreement_team_members.find(params[:id])
  end

  def spend_agreement_team_members
    spend_agreement
      .spend_agreement_team_members
      .exclude_ids(params[:exclude_ids])
      .preload(:user, :values)
  end

  def role_field_id
    company.fields.find_by(subject_type: 'Multiple', name: 'Spend Agreement Member Role').id
  end
end
