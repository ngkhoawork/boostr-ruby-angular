require 'representable/xml'

class Operative::DropdownOptionCustomFieldRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'options'

  property :name, exec_context: :decorator, wrap: :option

  def name
    represented
  end
end
