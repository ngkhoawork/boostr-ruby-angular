class Contracts::ActionsPolicy < ApplicationPolicy
  def authorize!(action)
    authorize?(action) || reject!
  end

  private

  def authorize?(action)
    raise ArgumentError, 'Undefined action' unless allowed_actions.include?(action.to_sym)

    send("#{action}?")
  end

  def index?
    true
  end

  def create?
    true
  end

  def update?
    (record.restricted? && user.is_not_legal?) ? false : true
  end

  def show?
    update?
  end

  def destroy?
    user.is_legal?
  end
end
