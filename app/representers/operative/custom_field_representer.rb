require 'representable/xml'

class Operative::CustomFieldRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'custom_fields'

  property :name, as: :apiName, exec_context: :decorator
  property :value, exec_context: :decorator

  def name
    represented[:name]
  end

  def value
    represented[:value]
  end
end
