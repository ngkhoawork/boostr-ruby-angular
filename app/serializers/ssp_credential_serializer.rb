class SspCredentialSerializer < ActiveModel::Serializer
  attributes :id, :key, :secret, :publisher_id, :parser_type, :type_id, :switched_on, :integration_provider, :integration_type

  PROVIDER_TYPES = { 1 => 'SSP SpotX',  2 => 'SSP Rubicon'}

  def integration_provider
    PROVIDER_TYPES[object.type_id]
  end

end
