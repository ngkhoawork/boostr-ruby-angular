class SspCredentialSerializer < ActiveModel::Serializer
  attributes :id, :key, :secret, :publisher_id, :parser_type, :switched_on, :integration_provider,
             :integration_type, :create_objects, :ssp_id
end
