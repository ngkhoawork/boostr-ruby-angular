class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process

    user = User.find_by_email('support@boostrcrm.com')
    if user.present?
      user_id = user.id
      company_id = user.company_id
      activity_type = user.company.activity_types.where(name: 'Email').first
      client_id = nil
      contact_emails = @email.to.collect {|to| to[:email]}
      contact_emails_added = []
      contacts = []
      contact_emails.each do |contact_email|
        addresses = Address.where(addressable_type: "Contact", email: contact_email)
        if addresses.count > 0
          client_id = addresses[0].addressable.client_id
          contacts << addresses[0].addressable
        else
          contact_emails_added << contact_email
        end
      end

      contact_emails_added.each do |contact_email|
        contact = Contact.create({
            name: contact_email,
            client_id: client_id,
            created_by: user.id,
            company_id: company_id,
            address_attributes: {
                email: contact_email
            }
                       })
        contacts << contact
      end

      activity = Activity.create({
          company_id: user.company_id,
          user_id: user.id,
          client_id: client_id,
          activity_type_name: 'Email',
          happened_at: Time.now,
          updated_by: user.id,
          created_by: user.id,
          comment: @email.body,
          activity_type_id: activity_type.id
                      })
      activity.contacts = contacts
      activity.save()
    end

  end
end