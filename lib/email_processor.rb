class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    user = User.by_email(@email.from[:email]).first
    # user = User.find_by_email('support@boostrcrm.com')
    if user.present?
      user_id = user.id
      company_id = user.company_id
      activity_type = user.company.activity_types.where(name: 'Email').first
      client_id = nil
      contact_emails = @email.to.collect {|to| to[:email]}
      contact_emails_added = []
      contacts = []
      contact_emails.each do |contact_email|
        if contact_email=="email@mail.boostrcrm.com" || contact_email=="email@postman.boostrcrm.com" || contact_email=="email@postman.staging.boostrcrm.com" || contact_email=="email@postman.testing.boostrcrm.com"
          next
        end
        addresses = Address.contacts_by_email(contact_email)

        if company_contact = Contact.find_by(id: addresses.map(&:addressable_id), company_id: company_id)
          if user.company.clients.exists? company_contact.client_id
            client_id = company_contact.client_id
          end
          contacts << company_contact
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
      if contacts.count > 0
        comment = "<div><strong>Email Subject - " + @email.subject + "</strong></div>"
        comment = comment + "<div><strong>Email Body - </strong></div>" + email_body
        activity = Activity.create({
            company_id: user.company_id,
            user_id: user.id,
            client_id: client_id,
            activity_type_name: 'Email',
            happened_at: Time.now,
            updated_by: user.id,
            created_by: user.id,
            comment: comment,
            activity_type_id: activity_type.id
                        })
        activity.contacts = contacts
        activity.save()

        @email.attachments.each_with_index do |attachment, index|
          file_name = "activities/" + activity.id.to_s + "/" + index.to_s + "-" + attachment.original_filename
          asset = Asset.create({
              attachable_id: activity.id,
              attachable_type: "Activity",
              asset_file_name: file_name,
              asset_file_size: attachment.tempfile.size(),
              asset_content_type: attachment.content_type,
              original_file_name: attachment.original_filename
                               })
          obj = S3_BUCKET.object(file_name)
          obj.put(body: attachment.tempfile)
        end
      end
    end

  end

  private

  def email_body
    (@email.raw_html || @email.raw_text || '').force_encoding("UTF-8").scrub('')
  end
end
