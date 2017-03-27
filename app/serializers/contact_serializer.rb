class ContactSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :client_id, :created_by, :updated_by,
             :created_at, :updated_at, :company_id, :activity_updated_at,
             :note, :formatted_name, :primary_client_json, :address

  def primary_client_json
    object.primary_client.serializable_hash(only: [:id, :name, :client_type_id]) rescue nil
  end
end
