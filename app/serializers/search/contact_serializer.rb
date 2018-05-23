class Search::ContactSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :name,
      :position,
      :email,
      :clients
  )

  def clients
    object.clients.map{|client| client.serializable_hash(only: [:id, :name])}
  end
end
