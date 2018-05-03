class ProcessRawContactDataService
  def initialize(guests, current_user)
    @guests       = extract_valid_guests(guests)
    @current_user = current_user
  end

  def perform
    company_contacts.ids + new_contacts.map(&:id)
  end

  private

  attr_reader :guests, :current_user

  def extract_valid_guests(guests)
    guests.select { |guest| guest.is_a? Hash }
  end

  def company_contacts
    @_company_contacts ||= begin
      guests_emails        = guests.map { |guest| guest[:address][:email] }
      existing_contact_ids = Address.contacts_by_email(guests_emails).pluck(:addressable_id)
      Contact.where(id: existing_contact_ids, company_id: company.id)
    end
  end

  def new_contacts
    new_incoming_contacts.inject([]) do |new_contacts, new_contact_data|
      contact = build_contact(new_contact_data)
      new_contacts << contact if contact.save
    end
  end

  def new_incoming_contacts
    existing_emails = company_contacts.map { |contact| contact.address.email }
    guests.reject { |guest| existing_emails.include?(guest[:address][:email]) }
  end

  def build_contact(new_contact_data)
    company.contacts.new(
      name:               new_contact_data[:name],
      address_attributes: { email: new_contact_data[:address][:email] },
      created_by:         current_user.id
    )
  end

  def company
    @_company ||= current_user.company
  end
end
