require 'representable/xml'

class Operative::AdvertiserRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:account'

  property :external_id, as: :externalId, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator, if: -> (options) { options[:create].eql? false }
  property :operative_name, as: :name, exec_context: :decorator
  property :roles, decorator: Operative::AccountRolesRepresenter, exec_context: :decorator
  # property :contacts, decorator: Operative::ContactsRepresenter, exec_context: :decorator, wrap: :contacts

  def external_id
    "boostr_#{represented.id}##"
  end

  def roles
    represented
  end

  def operative_id
    represented.integrations.operative.external_id
  end

  def operative_name
    represented.name
  end

  def contacts
    @_contact ||= represented.contacts.order(:created_at).first
  end
end
