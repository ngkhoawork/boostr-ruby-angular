require 'representable/xml'

class Operative::AdvertiserRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:account'

  property :external_id, as: :externalId, exec_context: :decorator
  property :operative_id, as: :id, exec_context: :decorator, if: -> (options) { options[:create].eql? false }
  property :operative_name, as: :name, exec_context: :decorator
  property :roles, decorator: Operative::AccountRolesRepresenter, exec_context: :decorator
  property :contact, decorator: Operative::ContactsRepresenter, exec_context: :decorator, wrap: :contacts,
           if: -> (options) { options[:advertiser].eql?(true) && options[:contact].eql?(true) }

  def external_id
    "boostr_#{advertiser.id}_#{advertiser.company.name}_account"
  end

  def roles
    advertiser
  end

  def operative_id
    advertiser.integrations.operative.external_id
  end

  def operative_name
    advertiser.name
  end

  def contact
    represented
  end

  def advertiser
    @_advertiser ||= represented.advertiser
  end
end
