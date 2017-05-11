class Activity < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :client
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :deal
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :activity_type

  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :contacts_info, -> { select(:id, :name) }, class_name: 'Contact'#, foreign_key: 'stage_id'

  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :assets, as: :attachable

  validates :company_id, presence: true
  validates_uniqueness_of :google_event_id, allow_nil: true, allow_blank: true

  after_create do
    if !deal_id.nil?
      deal = company.deals.find(deal_id)
      deal.update_attribute(:activity_updated_at, happened_at)
    elsif !client_id.nil?
      client = company.clients.find(client_id)
      client.update_attribute(:activity_updated_at, happened_at)
    end
  end

  scope :for_company, -> (id) { where(company_id: id) }
  scope :for_contact, -> (id) { joins(:activities_contacts).where('activities_contacts.contact_id = ?', id) }
  scope :for_time_period, -> (start_date, end_date) { where('activities.happened_at <= ? AND activities.happened_at >= ?', end_date, start_date) if start_date && end_date }

  def self.import(file, current_user)
    errors = []

    row_number = 0
    CSV.parse(file, headers: true) do |row|
      row_number += 1
      if row[1].present?
        begin
          happened_at = DateTime.strptime(row[1].strip, '%m/%d/%Y')
          if happened_at.year < 100
            happened_at = Date.strptime(row[1].strip, "%m/%d/%y")
          end
        rescue ArgumentError
          error = {row: row_number, message: ['Date must be a valid datetime'] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ['Date is empty'] }
        errors << error
        next
      end

      if row[2].nil? || row[2].blank?
        error = { row: row_number, message: ['Creator is empty'] }
        errors << error
        next
      else
        creator = current_user.company.users.where('email ilike ?', row[2]).first
        unless creator
          error = { row: row_number, message: ["User #{row[2]} could not be found"] }
          errors << error
          next
        end
      end

      if row[3].present?
        advertiser_type_id = Client.advertiser_type_id(current_user.company)
        advertisers = current_user.company.clients.by_type_id(advertiser_type_id).where('name ilike ?', row[3].strip)
        if advertisers.length > 1
          error = { row: row_number, message: ["Advertiser #{row[3]} matched more than one account record"] }
          errors << error
          next
        elsif advertisers.length == 0
          error = { row: row_number, message: ["Advertiser #{row[3]} could not be found"] }
          errors << error
          next
        else
          advertiser = advertisers.first
        end
      end

      if row[4].present?
        agency_type_id = Client.agency_type_id(current_user.company)
        agencies = current_user.company.clients.by_type_id(agency_type_id).where('name ilike ?', row[4].strip)
        if agencies.length > 1
          error = { row: row_number, message: ["Agency #{row[4]} matched more than one account record"] }
          errors << error
          next
        elsif agencies.length == 0
          error = { row: row_number, message: ["Agency #{row[4]} could not be found"] }
          errors << error
          next
        else
          agency = agencies.first
        end
      end

      if row[5].present?
        deals = current_user.company.deals.where('name ilike ?', row[5].strip)
        if deals.length > 1
          error = { row: row_number, message: ["Deal #{row[5]} matched more than one deal record"] }
          errors << error
          next
        elsif deals.length == 0
          error = { row: row_number, message: ["Deal #{row[5]} could not be found"] }
          errors << error
          next
        else
          deal = deals.first
        end
      end

      if row[6].present?
        type = current_user.company.activity_types.where('name ilike ?', row[6].strip).first
        unless type
          error = { row: row_number, message: ["Activity type #{row[6]} could not be found"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ['Activity type is empty'] }
        errors << error
        next
      end

      contact_list = []
      if row[8].present?
        contact_emails = row[8].split(';')

        contact_list_error = false
        contact_emails.each do |email|
          contact = Contact.by_email(email, current_user.company_id).first
          if contact
            contact_list << contact
          else
            error = { row: row_number, message: ["Activity contact #{email} could not be found in the contacts list"] }
            errors << error
            contact_list_error = true
            break
          end
        end

        if contact_list_error
          next
        end
      end

      activity_params = {
        user: creator,
        creator: creator,
        updator: creator,
        deal: deal,
        client: advertiser,
        agency: agency,
        activity_type_name: type.name,
        activity_type_id: type.id,
        happened_at: happened_at,
        comment: row[7] ? row[7].strip : nil
      }

      if row[0]
        begin
          activity = current_user.company.activities.find(row[0])
        rescue ActiveRecord::RecordNotFound
        end
      end

      if !(activity.present?)
        activity = current_user.company.activities.new
      end

      if activity.update_attributes(activity_params)
        activity.contacts << contact_list
      else
        error = { row: row_number, message: activity.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.merge(
        include: {
          :client => {},
          :agency => {},
          :deal => {
            :include => [
              :stage,
              :advertiser
            ]
          },
          :assets => {
              methods: [
                  :presigned_url
              ]
          },
          :contacts => {
            include: { address: {} }
            },
          :creator => {}
        }
      ).except(:override))
    end
  end
end
