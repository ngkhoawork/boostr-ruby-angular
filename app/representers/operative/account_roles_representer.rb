require 'representable/xml'

class Operative::AccountRolesRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :roles

  property :name, as: :internalName, exec_context: :decorator, wrap: :role

  def name
    represented.agency? ? 'buying_agency' : 'primary_advertiser'
  end
end
