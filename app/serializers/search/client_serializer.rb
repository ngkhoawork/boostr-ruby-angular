class Search::ClientSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :name,
      :client_type,
      :client_category
  )

  has_many :client_member_info, key: :client_members, serializer: Clients::ClientMemberSerializer

  private

  def client_category
    object.client_category.serializable_hash(only: [:id, :name]) rescue nil
  end
end
