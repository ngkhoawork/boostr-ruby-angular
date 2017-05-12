class ClientContacts::ContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :address,
    :job_level
  )

  def job_level
    object.job_level(@options[:contact_options])
  end
end
