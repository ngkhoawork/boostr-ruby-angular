require 'representable/xml'

class Operative::ContactsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :contact

  property :roles, decorator: Operative::ContactRolesRepresenter, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator, if: -> (options) { options[:create].eql? false }
  property :external_id, as: :externalId, exec_context: :decorator

  def roles
    contact
  end

  def operative_id
    contact.integrations.operative.external_id
  end

  def external_id
    "boostr_#{contact.id}_#{contact.company.name}_contact"
  end

  def contact
    @_contact ||= represented.ordered_by_created_at_billing_contacts.first.contact
  end
end
