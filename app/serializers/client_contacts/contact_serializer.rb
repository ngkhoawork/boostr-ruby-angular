class ClientContacts::ContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :address,
    :job_level,
    :non_primary_client_contacts,
    :position
  )

  def job_level
    object.job_level(@options[:contact_options])
  end
end
