class Contact < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, counter_cache: true
  belongs_to :company

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validates :position, presence: true

  scope :for_client, -> client_id { where(client_id: client_id) if client_id.present? }

  def as_json(options = {})
    super(options.merge(include: [:address, :client, :company]))
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
          city: row[4],
          state: row[5],
          zip: row[6],
          phone: row[7],
          mobile: row[8],
          email: row[9]
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
end
