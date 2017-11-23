class OnlyAdminsAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    if subject.instance_of?(User) && subject.id == user.id && action == :update
      user.is?(:superadmin) || user.is?(:supportadmin)
    elsif action == :create || action == :update || action == :destroy
      user.is?(:superadmin)
    else
      true
    end
  end
end