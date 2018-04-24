class Egnyte::Actions::Connect::Company < Egnyte::Actions::Connect::Base
  private

  def auth_class
    EgnyteIntegration
  end

  def egnyte_integration
    auth_record
  end
end
