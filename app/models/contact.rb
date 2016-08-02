class Contact < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, counter_cache: true
  belongs_to :company

  has_one :address, as: :addressable, dependent: :destroy

  has_and_belongs_to_many :activities, after_add: :update_activity_updated_at

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validate :email_is_present?
  validate :email_uniqueness

  scope :for_client, -> client_id { where(client_id: client_id) if client_id.present? }

  def as_json(options = {})
    super(options.merge(
      include: {
        address: {},
        client: {},
        activities: {
          include: [:creator, :contacts]
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

    if !current_user.is?(:superadmin)
      error = { message: ['Permission denied'] }
      errors << error
    else
      row_number = 0
      CSV.parse(file, headers: true) do |row|
        row_number += 1

        unless client = Client.where(company_id: current_user.company_id, name: row[1]).first
          error = { row: row_number, message: ['Client could not be found'] }
          errors << error
          next
        end

        find_params = {
          name: row[0],
          position: row[2],
          client_id: client.id,
          company_id: current_user.company_id
        }

        create_params = {
          created_by: current_user.id
        }

        contact = Contact.find_or_initialize_by(find_params)
        unless contact.update_attributes(create_params)
          error = { row: row_number, message: contact.errors.full_messages }
          errors << error
          next
        end

        find_address_params = {
          addressable_id: contact.id,
          addressable_type: 'Contact',
        }

        address_params = {
          street1: row[3],
          street2: row[4],
          city: row[5],
          state: row[6],
          zip: row[7],
          phone: row[8],
          mobile: row[9],
          email: row[10]
        }

        address = Address.find_or_initialize_by(find_address_params)      
        unless address.update_attributes(address_params)      
          error = { row: row_number, message: address.errors.full_messages }
          errors << error
          next
        end
      end
    end
    errors
  end

  private

  def email_is_present?
    unless address and address.email
      errors.add(:email, "can't be blank")
    end
  end

  def email_uniqueness
    if address && Address.where(email: address.email).where.not(addressable_id: id).any?
      errors.add :email, 'has already been taken'
    end
  end

  def update_activity_updated_at(activity)
    activity_updated_at = activity.happened_at
    save
  end
end
