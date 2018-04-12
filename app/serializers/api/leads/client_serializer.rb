class Api::Leads::ClientSerializer < ActiveModel::Serializer
  attributes :id, :name, :type

  def type
    object.client_type.name
  end
end
