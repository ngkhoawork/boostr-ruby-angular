class Api::Dataexport::UsersController < Api::Dataexport::BaseController
  private

  def collection
    current_user.company.users
  end

  def serializer_class
    ::Dataexport::UserSerializer
  end
end
