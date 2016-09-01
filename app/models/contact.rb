class Contact < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, counter_cache: true
  belongs_to :company

  has_many :reminders, as: :remindable, dependent: :destroy
  has_one :address, as: :addressable

  has_and_belongs_to_many :activities, after_add: :update_activity_updated_at

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validate :email_is_present?
  validate :email_unique?

  scope :for_client, -> client_id { where(client_id: client_id) if client_id.present? }
  scope :unassigned, -> user_id { where(client_id: nil, created_by: user_id) }

  def as_json(options = {})
    super(options.merge(
      include: {
        address: {},
        client: {},
        activities: {
          include: {
            creator: {},
            contacts: {},
            assets: {
              methods: [
                :presigned_url
              ]
            }
          }
        }
      },
      methods: [:formatted_name]
    ))
  end

  def formatted_name
    name
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
      unless client = Client.where(company_id: current_user.company_id, name: row[1]).first
        error = { row: row_number, message: ['Client could not be found'] }
        errors << error
        next
      end

      find_params = {
        company_id: current_user.company_id,
        addresses: {
          email: row[3]
        }
      }

      contact = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").find_by(find_params)

      address_params = {
        email: row[3],
        street1: row[4],
        street2: row[5],
        city: row[6],
        state: row[7],
        zip: row[8],
        phone: row[9],
        mobile: row[10],
      }
      contact_params = {
          name: row[0],
          client_id: client.id,
          position: row[2],
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


      unless contact.update_attributes(contact_params)
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
    unless address and address.email
      errors.add(:email, "can't be blank")
    end
  end

  def email_unique?
    contact = Contact.joins("INNER JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type='Contact'").find_by({company_id: company_id, addresses: {email: address.email}})
    if contact.present?
      errors.add(:email, "has already been taken")
    end
  end

  def update_activity_updated_at(activity)
    activity_updated_at = activity.happened_at
    save
  end
end
