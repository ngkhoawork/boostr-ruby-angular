class ApplicationPolicy
  attr_reader :user, :record

  def self.allowed_actions
    %i(index create update show destroy)
  end

  def initialize(user, record)
    raise ArgumentError, 'Must be present' unless user

    @user = user
    @record = record
  end

  private

  delegate :allowed_actions, to: :class

  def reject!
    raise NotAuthorizedError
  end

  class NotAuthorizedError < StandardError; end
end
