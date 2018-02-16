class Api::Dataexport::DealMembersController < Api::Dataexport::BaseController
  private

  def collection
    DealMember.where(deal_id: current_user.company.deals.pluck(:id)).includes(:user)
  end

  def serializer_class
    ::Dataexport::DealMemberSerializer
  end
end
