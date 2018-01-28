class Api::Dataexport::IoMembersController < Api::Dataexport::BaseController
  private

  def collection
    IoMember.where(io_id: current_user.company.ios.pluck(:id))
  end

  def serializer_class
    ::Dataexport::IoMemberSerializer
  end
end
