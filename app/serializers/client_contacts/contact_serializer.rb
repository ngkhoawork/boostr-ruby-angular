class ClientContacts::ContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :address,
    :job_level,
    :non_primary_client_contacts,
    :primary_client_contact,
    :position,
    :contact_cf,
    :note
  )

  def job_level
    object.job_level_for(@options[:contact_options])
  end
end
