require 'representable/xml'

class Operative::ContactRolesRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :roles

  property :name, as: :internalName, exec_context: :decorator, wrap: :role

  def name
    'billing_contact'
  end
end
