require 'representable/xml'

class Operative::AgencyRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:account'

  property :external_id, as: :externalId, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator, if: -> (options) { options[:create].eql? false }
  property :operative_name, as: :name, exec_context: :decorator
  property :roles, decorator: Operative::AccountRolesRepresenter, exec_context: :decorator
  property :contact, decorator: Operative::ContactsRepresenter, exec_context: :decorator, wrap: :contacts,
           if: -> (options) { options[:advertiser].eql? false }

  def external_id
    "boostr_#{agency.id}_#{agency.company.name}_account"
  end

  def roles
    agency
  end

  def operative_id
    agency.integrations.operative.external_id
  end

  def operative_name
    agency.name
  end

  def contact
    represented
  end

  def agency
    @_agency ||= represented.agency
  end
end
