class EgnyteService
  require 'egnyte'

  def initialize(current_user)
    session = Egnyte::Session.new({
        key: 'api_key',
        domain: 'egnyte_domain'
    })


    @client = Egnyte::Client.new(session)
  end
end