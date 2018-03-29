class Api::EalertTemplates::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :type,
    :recipients
  )

  has_many :fields, serializer: Api::EalertTemplates::Fields::BaseSerializer
end
