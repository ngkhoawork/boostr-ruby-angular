require 'representable/xml'

class Operative::ContactsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :contact

  property :roles, decorator: Operative::ContactRolesRepresenter, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator
  property :external_id, as: :externalId, exec_context: :decorator
  property :first_name, as: :firstName, exec_context: :decorator
  property :last_name, as: :lastName, exec_context: :decorator

  def roles
    contact
  end

  def operative_id
    contact.integrations.operative.external_id
  end

  def external_id
    "boostr_#{represented.id}#"
  end

  def contact
    @_contact ||= represented.contacts.order(:created_at).first
  end

  def contact_full_name
    @_full_name ||= represented.name.partition(' ')
  end

  def first_name
    contact_full_name.first
  end

  def last_name
    contact_full_name.last
  end
end
