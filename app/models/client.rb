class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent_client, class_name: "Client"

  has_many :child_clients, class_name: "Client", foreign_key: :parent_client_id
  has_many :client_members
  has_many :users, through: :client_members
  # has_many :contacts
  has_many :contacts, -> { uniq }, through: :client_contacts
  has_many :client_contacts, dependent: :destroy
  has_many :revenues
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id'
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id'
  has_many :values, as: :subject
  has_many :activities
  has_many :reminders, as: :remindable, dependent: :destroy

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address, :values

  validates :name, presence: true

  before_create :ensure_client_member

  scope :by_type_id, -> type_id { where(client_type_id: type_id) if type_id.present? }
  scope :opposite_type_id, -> type_id { where.not(client_type_id: type_id) if type_id.present? }
  scope :exclude_ids, -> ids { where.not(id: ids) }

  def self.to_csv
    attributes = {
      id: 'Client ID',
      name: 'Name'
    }

    CSV.generate(headers: true) do |csv|
      csv << attributes.values

      all.each do |client|
        csv << attributes.map{ |key, value| client.send(key) }
      end
    end
  end

  def advertiser?
    is_advertiser = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Advertiser"
        is_advertiser = true
        break
      end
    end
    is_advertiser
  end

  def agency?
    is_agency = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Agency"
        is_agency = true
        break
      end
    end
    is_agency
  end

  def deals_count
    advertiser_deals_count + agency_deals_count
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    f_name = name
    if !address.nil?
      if !address.city.nil?
        f_name = f_name + ', '+ address.city.to_s
      end
      if !address.state.nil?
        f_name = f_name + ', '+ address.state.to_s
      end
    end
    f_name
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        address: {},
        parent_client: {},
        contacts: {},
        values: {
          methods: [:value],
          include: [:option]
        },
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
        }},
      methods: [:deals_count, :fields, :formatted_name]
    ))
  end

  def ensure_client_member
    return true if created_by.blank?
    return true if client_members.detect { |member| member.user_id == created_by }

    share = 0
    if advertiser?
      share = 100
    end
    client_members.build(user_id: created_by, share: share)
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

        if !row[10].blank?
          unless user = User.where('lower(email) = ? and company_id = ?', row[10].downcase, current_user.company_id).first
            error = { row: row_number, message: ['Sales Rep 1 could not be found'] }
            errors << error
            next
          end
        end

        if row[13].present? && !row[13].blank?
          unless user1 = User.where('lower(email) = ? and company_id = ?', row[13].downcase, current_user.company_id).first
            error = { row: row_number, message: ['Sales Rep 2 could not be found'] }
            errors << error
            next
          end
        end

        find_params = {
          company_id: current_user.company_id,
          name: row[0]
        }

        create_params = {
          website: row[9]
        }

        client = Client.find_or_initialize_by(find_params)
        unless client.update_attributes(create_params)
          error = { row: row_number, message: client.errors.full_messages }
          errors << error
        end

        update_params = {
          created_by: current_user.id
        }

        client.update_attributes(update_params)

        find_address_params = {
          addressable_id: client.id,
          addressable_type: 'Client',
        }

        address_params = {
          street1: row[2],
          street2: row[3],
          city: row[4],
          state: row[5],
          zip: row[6],
          phone: row[7],
          email: row[8]
        }

        address = Address.find_or_initialize_by(find_address_params)      
        unless address.update_attributes(address_params)      
          error = { row: row_number, message: address.errors.full_messages }
          errors << error
          next
        end

        option_error = insert_option(current_user, 'Client', client.id, row[1])
        if option_error.present?
          error = { row: row_number, message: option_error }
          errors << error
          next
        end

        if user.present?
          find_client_member_params = {
            client_id: client.id,
            user_id: user.id
          }

          client_member_params = {
            share: row[11]
          }

          client_member = ClientMember.find_or_initialize_by(find_client_member_params)
          unless client_member.update_attributes(client_member_params)
            error = { row: row_number, message: client_member.errors.full_messages }
            errors << error
            next
          end

          option_error = insert_option(current_user, 'ClientMember', client_member.id, row[12])
          if option_error.present?
            error = { row: row_number, message: option_error }
            errors << error
            next
          end
        end

        if user1.present?
          find_client_member1_params = {
            client_id: client.id,
          user_id: user1.id
          }

          client_member1_params = {
            share: row[14]
          }

          client_member1 = ClientMember.find_or_initialize_by(find_client_member1_params)
          unless client_member1.update_attributes(client_member1_params)
            error = { row: row_number, message: client_member1.errors.full_messages }
            errors << error
            next
          end

          option_error = insert_option(current_user, 'ClientMember', client_member1.id, row[15])
          if option_error.present?
            error = { row: row_number, message: option_error }
            errors << error
            next
          end

        end
      end
    end
    errors
  end

  def self.insert_option(current_user, type, id, name)
    option_params = {
      company_id: current_user.company_id,
      name: name
    }

    unless option = Option.find_by(option_params)
      error = [type+': '+name+' '+'Option could not be found']
      return error
    end

    value_params = {
      company_id: current_user.company_id,
      subject_type: type,
      subject_id: id,
      field_id: option.field_id,
      value_type: 'Option',
      option_id: option.id
    }

    unless value = Value.create(value_params)
      error = { message: value.errors.full_messages }
      return error
    end
  end

end
