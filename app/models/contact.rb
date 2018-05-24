class Contact < ActiveRecord::Base
  SAFE_COLUMNS = %i{name position created_at updated_at}

  include PgSearch

  multisearchable against: [:name, :email, :client_names], 
                  additional_attributes: lambda { |contact| { company_id: contact.company_id } },
                  if: lambda { |contact| !contact.deleted? }

  acts_as_paranoid

  WEB_FORM_LEAD = 'web-form lead'.freeze
  MARKETING_LEAD = 'marketing lead'.freeze
  TRADESHOW_LEAD = 'tradeshow lead'.freeze
  OTHER_LEAD = 'other lead'.freeze
  OTHER = 'other'.freeze

  belongs_to :company
  belongs_to :client
  belongs_to :account_dimension
  belongs_to :publisher

  has_one :primary_client, through: :primary_client_contact, source: :client
  has_one :primary_client_contact, -> { where('client_contacts.primary = ?', true) }, class_name: 'ClientContact'
  has_one :contact_cf, dependent: :destroy, inverse_of: :contact

  has_many :clients, -> { uniq }, through: :client_contacts
  has_many :account_dimensions, -> { uniq }, through: :account_contacts
  has_many :account_contacts, class_name: 'ClientContact'

  has_many :client_contacts, dependent: :destroy
  has_many :non_primary_client_contacts, -> { where('client_contacts.primary = ?', false) }, class_name: 'ClientContact'
  has_many :non_primary_clients, -> { uniq }, through: :non_primary_client_contacts, source: :client

  has_many :deals, -> { uniq }, through: :deal_contacts
  has_many :deal_contacts, dependent: :destroy
  has_many :reminders, as: :remindable, dependent: :destroy
  has_one :address, as: :addressable
  has_many :integrations, as: :integratable
  has_many :values, as: :subject
  has_many :leads

  has_and_belongs_to_many :latest_happened_activity, -> {
    order('activities.happened_at DESC').limit(1)
  }, class_name: 'Activity'

  has_and_belongs_to_many :activities, after_add: :update_activity_updated_at

  delegate :email, :street1, :street2, :city, :state, :zip, :phone, :mobile, :country, to: :address, allow_nil: true
  delegate :name, to: :client, prefix: true, allow_nil: true

  accepts_nested_attributes_for :contact_cf
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :values

  validates :name, presence: true
  validate :email_is_present?
  validate :email_unique?

  scope :for_client, -> client_id { Contact.joins("INNER JOIN client_contacts as cc1 ON contacts.id=cc1.contact_id").where("cc1.client_id = ?", client_id) if client_id.present? }
  scope :not_for_client, -> client_id { Contact.joins("INNER JOIN client_contacts as cc1 ON contacts.id=cc1.contact_id").where("cc1.client_id = ?", client_id) if client_id.present? }
  scope :for_primary_client, -> client_id { Contact.joins("INNER JOIN client_contacts as cc ON cc.contact_id = contacts.id").where("cc.client_id = ? and cc.primary IS TRUE", client_id) if client_id.present? }
  scope :unassigned, -> user_id { where(created_by: user_id).where('id NOT IN (SELECT DISTINCT(contact_id) from client_contacts)') }
  scope :by_email, -> email, company_id {
    joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").where("addresses.email ilike ? and contacts.company_id=?", email, company_id)
  }
  scope :total_count, -> { except(:order, :limit, :offset).count.to_s }
  scope :by_client_ids, -> ids do
    joins("INNER JOIN client_contacts ON contacts.id=client_contacts.contact_id").where("client_contacts.client_id in (:q)", {q: ids}).order(:name).distinct
  end
  scope :by_name, -> name { where('contacts.name ilike ?', "%#{name}%") if name.present? }
  scope :by_primary_client_name, -> client_name do
    joins(
      "INNER JOIN client_contacts as primary_client_contact ON contacts.id=primary_client_contact.contact_id and (primary_client_contact.primary = #{true})"
    ).joins(
      'INNER JOIN clients as primary_clients ON primary_clients.id = primary_client_contact.client_id'
    ).where('primary_clients.name ilike ?', client_name) if client_name.present?
  end

  scope :by_city, -> city_name do
    joins(:address).where("addresses.city ilike ?", city_name) if city_name.present?
  end

  scope :by_job_level, -> job_level do
    joins(:values).where('values.option_id in (?)', Option.by_name(job_level).ids) if job_level.present?
  end

  scope :by_country, -> country do
    joins(:address).where("addresses.country ilike ?", country) if country.present?
  end

  scope :by_last_touch, -> start_date, end_date do
    where(activity_updated_at: start_date..end_date) if (start_date && end_date).present?
  end

  scope :less_than, -> activity_updated_at do
    where('activity_updated_at < ? OR activity_updated_at is null', activity_updated_at)
  end

  scope :greater_than_happened_at, -> happened_at do
    joins(:activities).where('activities.happened_at > ?', happened_at)
  end

  scope :less_than_happened_at, -> happened_at do
    joins(:activities).where('activities.happened_at <= ? OR activities.happened_at is null', happened_at).distinct
  end

  after_save do
    if client_id_changed? && !client_id.nil?
      relation = ClientContact.find_or_initialize_by(contact_id: id, client_id: client_id)
      relation.primary = true if client_id_was.nil?
      relation.save
    elsif client_id_changed? && client_id.nil?
      self.clients = []
    elsif client_id.present?
      relation = ClientContact.find_or_initialize_by(contact_id: id, client_id: client_id)
      relations = ClientContact.where(contact_id: id)
      relation.primary = true if relations.count == 0
      relation.save
    end
    update_pg_search_document
  end

  def primary_client_json
    self.primary_client.serializable_hash(only: [:id, :name, :client_type_id]) rescue nil
  end

  def formatted_name
    name
  end

  def update_primary_client
    primary = self.primary_client
    if primary && primary.id != self.client_id
      self.clients.delete(primary.id)
      client_contacts.where(client_id: self.client_id).update_all(primary: true)
    end
    self.reload
  end

  def job_level
    return nil if values.empty?

    job_level_field_id = company.fields.where(name: 'Job Level').pluck(:id).first
    job_level_value = values.find_by(field_id: job_level_field_id)
    return job_level_value.option.name if job_level_value.present?
    return nil
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'contact', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, headers: true) do |row|
      import_log.count_processed

      if row[3].nil? || row[3].blank?
        import_log.count_failed
        import_log.log_error(['Email is empty'])
        next
      end

      if row[1].nil? || row[1].blank?
        import_log.count_failed
        import_log.log_error(['Account is empty'])
        next
      end

      if row[0].nil? || row[0].blank?
        import_log.count_failed
        import_log.log_error(['Name is empty'])
        next
      end

      unless client = Client.where("company_id = ? and lower(name) = ? ", current_user.company_id, row[1].strip.downcase).first
        import_log.count_failed
        import_log.log_error(['Account ' + row[1].to_s + ' could not be found'])
        next
      end
      agency_data_list = []

      if row[12].present?
        agency_list = row[12].split(";")

        agency_list_error = false
        agency_list.each do |agency_name|
          if agency = Client.where("company_id = ? and lower(name) = ? ", current_user.company_id, agency_name.strip.downcase).first
            agency_data_list << agency
          else
            import_log.count_failed
            import_log.log_error(['Account ' + agency_name.to_s + ' could not be found'])
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
        country: row[8]&.strip,
        zip: row[9].nil? ? nil : row[9].strip,
        phone: row[10].nil? ? nil : row[10].strip,
        mobile: row[11].nil? ? nil : row[11].strip,
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
        import_log.count_imported

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
        import_log.count_failed
        import_log.log_error(contact.errors.full_messages)
        next
      end
    end

    import_log.save
  end

  def self.metadata(company_id)
    {
      workplaces: Contact.where(company_id: company_id).joins(:primary_client).distinct.pluck('clients.name'),
      job_levels: Field.where(company_id: company_id, subject_type: 'Contact', name: 'Job Level').joins(:options).pluck('options.name'),
      cities: Contact.where(company_id: company_id).joins(:address).where.not(addresses: {city: nil}).pluck('addresses.city').uniq,
      countries: ISO3166::Country.all_translated
    }
  end

  def job_level_for(company_fields)
    if self.values.present? && company_fields.present?
      field_id = company_fields.first.field_id
      value = self.values.find do |el|
        el.field_id == field_id
      end
      option = company_fields.find do |el|
        el.id == value.option_id
      end if value
    end

    if option
      option.name
    else
      nil
    end
  end

  def client_names
    clients.pluck(:name).join(' ')
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
    self.activity_updated_at = activity.happened_at
    save
  end
end
