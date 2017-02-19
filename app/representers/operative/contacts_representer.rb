require 'representable/xml'

class Operative::ContactsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :contact

  property :roles, decorator: Operative::ContactRolesRepresenter, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator
  property :external_id, as: :externalId, exec_context: :decorator

  def roles
    contact
  end

  def operative_id
    contact.integrations.operative.external_id
  end

  def external_id
    "boostr_#{represented.id}##"
  end

  def contact
    represented
  end

  def contact_full_name
    @_full_name ||= represented.name.partition(' ')
  end
end
