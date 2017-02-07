class Contact < ActiveRecord::Base
  acts_as_paranoid

  has_many :clients, -> { uniq }, through: :client_contacts
  has_many :client_contacts, dependent: :destroy
  belongs_to :company

  has_many :deals, -> { uniq }, through: :deal_contacts
  has_many :deal_contacts, dependent: :destroy
  has_many :reminders, as: :remindable, dependent: :destroy
  has_one :address, as: :addressable

  has_and_belongs_to_many :activities, after_add: :update_activity_updated_at

  delegate :email, :street1, :street2, :city, :state, :zip, :phone, :mobile, :country, to: :address, allow_nil: true

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validate :email_is_present?
  validate :email_unique?

  scope :for_client, -> client_id { where(client_id: client_id) if client_id.present? }
  scope :unassigned, -> user_id { where(created_by: user_id).where('id NOT IN (SELECT DISTINCT(contact_id) from client_contacts)') }
  scope :by_email, -> email, company_id {
    Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").where("addresses.email ilike ? and contacts.company_id=?", email, company_id)
  }
  scope :total_count, -> { except(:order, :limit, :offset).count.to_s }
  scope :by_client_ids, -> limit, offset, ids { Contact.joins("INNER JOIN client_contacts ON contacts.id=client_contacts.contact_id").where("client_contacts.client_id in (:q)", {q: ids}).order(:name).limit(limit).offset(offset).distinct }

  scope :by_name, -> name { where('contacts.name ilike ?', "%#{name}%") if name.present? }

  after_save do
    if client_id_changed? && !client_id.nil?
      relation = ClientContact.find_or_initialize_by(contact_id: id, client_id: client_id)
      relation.primary = true if client_id_was.nil?
      relation.save
    elsif client_id_changed? && client_id.nil?
      self.clients = []
    end
  end

  def as_json(options = {})
    super(options.deep_merge(
      include: {
        address: {}
      },
      methods: [:formatted_name, :primary_client_json]
    ))
  end

  def formatted_name
    name
  end

  def primary_client
    Client.joins("INNER JOIN client_contacts ON clients.id=client_contacts.client_id")
          .where("client_contacts.contact_id = ?", self.id)
          .where("client_contacts.primary = 't'").first
  end

  def primary_client_json
    primary_client.as_json(override: true, only: [:id, :name, :client_type_id])
  end

  def update_primary_client
    primary = self.primary_client
    if primary && primary.id != self.client_id
      self.clients.delete(primary.id)
      client_contacts.where(client_id: self.client_id).update_all(primary: true)
    end
  end

  def self.import(file, current_user)
    errors = []

    # if !current_user.is?(:superadmin)
    #   error = { message: ['Permission denied'] }
    #   errors << error
    # else
    row_number = 0
    CSV.parse(file, headers: true) do |row|
      row_number += 1
      # unless client = Client.where(company_id: current_user.company_id, name: row[1]).first
      if row[3].nil? || row[3].blank?
        error = { row: row_number, message: ['Email is empty'] }
        errors << error
        next
      end

      if row[1].nil? || row[1].blank?
        error = { row: row_number, message: ['Account is empty'] }
        errors << error
        next
      end

      if row[0].nil? || row[0].blank?
        error = { row: row_number, message: ['Name is empty'] }
        errors << error
        next
      end

      unless client = Client.where("company_id = ? and lower(name) = ? ", current_user.company_id, row[1].strip.downcase).first
        error = { row: row_number, message: ['Account ' + row[1].to_s + ' could not be found'] }
        errors << error
        next
      end
      agency_data_list = []

      if row[11].present?
        agency_list = row[11].split(";")

        agency_list_error = false
        agency_list.each do |agency_name|
          if agency = Client.where("company_id = ? and lower(name) = ? ", current_user.company_id, agency_name.strip.downcase).first
            agency_data_list << agency
          else
            error = { row: row_number, message: ['Account ' + agency_name.to_s + ' could not be found'] }
            errors << error
            agency_list_error = true
            break
          end
        end
        if agency_list_error
          next
        end
      end


      find_params = {
        company_id: current_user.company_id,
        addresses: {
          email: row[3]
        }
      }

      # contact = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").find_by(find_params)
      contacts = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").where("contacts.company_id=? and lower(addresses.email)=?", current_user.company_id, row[3].strip.downcase)
      if (contacts.length > 0)
        contact = contacts.first
      else
        contact = nil
      end
      address_params = {
        email: row[3].nil? ? nil : row[3].strip,
        street1: row[4].nil? ? nil : row[4].strip,
        street2: row[5].nil? ? nil : row[5].strip,
        city: row[6].nil? ? nil : row[6].strip,
        state: row[7].nil? ? nil : row[7].strip,
        zip: row[8].nil? ? nil : row[8].strip,
        phone: row[9].nil? ? nil : row[9].strip,
        mobile: row[10].nil? ? nil : row[10].strip,
      }
      contact_params = {
          name: row[0].nil? ? nil : row[0].strip,
          client_id: client.id,
          position: row[2].nil? ? nil : row[2].strip,
          created_by: current_user.id
      }
      if contact.present?
        address_params[:id] = contact.address.id
        contact_params[:id] = contact.id
      else
        contact = Contact.create({company_id: current_user.company_id, address_attributes: {email: row[3]}})
        contact_params[:id] = contact.id
      end
      contact_params[:address_attributes] = address_params

      if contact.update_attributes(contact_params)
        ClientContact.delete_all(client_id: client.id, contact_id: contact.id, primary: false)
        primary_client_contact = ClientContact.find_by({contact_id: contact.id, primary: true})
        if primary_client_contact.nil?
          contact.client_contacts.create({client_id: client.id, primary: true})
        else
          primary_client_contact.client_id = client.id
          primary_client_contact.save!
        end
        agency_data_list.each do |agency|
          unless client_contact = ClientContact.find_by({contact_id: contact.id, client_id: agency.id})
            contact.client_contacts.create({client_id: agency.id, primary: false})
          end
        end
      else
        error = { row: row_number, message: contact.errors.full_messages }
        errors << error
        next
      end
    end
    # end
    errors
  end

  private

  def email_is_present?
    unless address and address.email and address.email.present?
      errors.add(:email, "can't be blank")
    end
  end

  def email_unique?
    if address && address.email.present?
      if id
        contact = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").where("contacts.company_id=? and addresses.email ilike ? and contacts.id != ?", company_id, address.email, id)
      else
        contact = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").where("contacts.company_id=? and addresses.email ilike ?", company_id, address.email)
      end

      if contact.present?
        errors.add(:email, "has already been taken")
      end
    end
  end

  def update_activity_updated_at(activity)
    activity_updated_at = activity.happened_at
    save
  end
end
