require 'representable/xml'

class Operative::AdvertiserRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:account'

  property :external_id, as: :externalId, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator#, if: -> (options) { options[:create].eql? true }
  property :operative_name, as: :name, exec_context: :decorator
  property :roles, decorator: Operative::RolesRepresenter, exec_context: :decorator

  def external_id
    'os-123'
    # represented.id.to_s
  end

  def roles
    represented
  end

  def operative_id
    22
    # represented.integrations.operative.external_id
  end

  def operative_name
    'Oscarik'
  end
end
