require 'representable/xml'

class Operative::AdvertiserRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :account

  property :external_id, as: :externalId, exec_context: :decorator

  def external_id
    represented.id.to_s
  end
end
