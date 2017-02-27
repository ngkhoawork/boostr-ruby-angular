require 'representable/xml'

class Operative::Deals::Single < API::Single
  include Representable::XML

  self.representation_wrap = :Collection

  property :order_collection, exec_context: :decorator, decorator: Operative::OrderCollectionRepresenter
  property :collection_xmlns, attribute: true, exec_context: :decorator, as: :xmlns
  property :collection_xmlns_v1, attribute: true, exec_context: :decorator, as: 'xmlns:v1'
  property :collection_xmlns_v2, attribute: true, exec_context: :decorator, as: 'xmlns:v2'

  def collection_xmlns
    'http://www.operative.com/api'
  end

  def collection_xmlns_v1
    'htt0p://www.operative.com/api/v1'
  end

  def collection_xmlns_v2
    'http://www.operative.com/api/v2'
  end

  def order_collection
    represented
  end
end
