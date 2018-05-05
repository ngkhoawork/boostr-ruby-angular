class Egnyte::Actions::Connect::User < Egnyte::Actions::Connect::Base
  private

  def auth_class
    EgnyteAuthentication
  end

  def egnyte_integration
    auth_record&.user&.company&.egnyte_integration || (raise 'Egnyte integration does not exist')
  end
end
