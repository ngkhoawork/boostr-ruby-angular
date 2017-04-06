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
  has_many :agency_activities, class_name: 'Activity', foreign_key: 'agency_id'
  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :account_dimensions, foreign_key: 'id', dependent: :destroy

  belongs_to :client_category, class_name: 'Option', foreign_key: 'client_category_id'
  belongs_to :client_subcategory, class_name: 'Option', foreign_key: 'client_subcategory_id'
  has_one :address, as: :addressable
  has_many :integrations, as: :integratable

  delegate :street1, :street2, :city, :state, :zip, :phone, :country, to: :address, allow_nil: true
  delegate :name, to: :client_category, prefix: :category, allow_nil: true
  delegate :name, to: :parent_client, prefix: true, allow_nil: true

  accepts_nested_attributes_for :address, :values

  validates :name, :client_type_id, presence: true

  before_create :ensure_client_member

  scope :by_type_id, -> type_id { where(client_type_id: type_id) if type_id.present? }
  scope :opposite_type_id, -> type_id { where.not(client_type_id: type_id) if type_id.present? }
  scope :exclude_ids, -> ids { where.not(id: ids) }
  scope :by_contact_ids, -> ids { Client.joins("INNER JOIN client_contacts ON clients.id=client_contacts.client_id").where("client_contacts.contact_id in (:q)", {q: ids}).order(:name).distinct }
  scope :by_category, -> category_id { where(client_category_id: category_id) if category_id.present? }
  scope :by_subcategory, -> subcategory_id { where(client_subcategory_id: subcategory_id) if subcategory_id.present? }
  scope :by_name, -> name { where('clients.name ilike ?', "%#{name}%") if name.present? }

  ADVERTISER = 10
  AGENCY = 11

  def self.to_csv(company)
    header = [
      :Id,
      :Name,
      :Type,
      :Parent,
      :Category,
      :Subcategory,
      :Address,
      :City,
      :State,
      :Zip,
      :Phone,
      :Website,
      :Replace_team,
      :Teammembers
    ]

    agency_type_id = self.agency_type_id(company)
    advertiser_type_id = self.advertiser_type_id(company)

    CSV.generate(headers: true) do |csv|
      csv << header

      all
      .includes(
        :parent_client,
        :address,
        :client_category,
        :client_subcategory,
        client_members: [:user]
      )
      .order(:id).each do |client|
        type_id = nil
        if advertiser_type_id == client.client_type_id
          type_id = 'Advertiser'
        elsif agency_type_id == client.client_type_id
          type_id = 'Agency'
        end

        team_members = client.client_members.each_with_object([]) do |member, memo|
          memo << member.user.email + '/' + member.share.to_s
        end

        line = []
        line << client.id
        line << client.name
        line << type_id
        line << (client.parent_client.try(:name))
        line << (client.client_category.try(:name))
        line << (client.client_subcategory.try(:name))
        line << (client.address.nil? ? nil : client.address.street1)
        line << (client.address.nil? ? nil : client.address.city)
        line << (client.address.nil? ? nil : client.address.state)
        line << (client.address.nil? ? nil : client.address.zip)
        line << (client.address.nil? ? nil : client.address.phone)
        line << client.website
        line << nil
        line << team_members.join(';')

        csv << line
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
    if options[:override]
      super(options)
    else
      super(options.deep_merge(
        include: {
          address: {},
          parent_client: { only: [:id, :name] },
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
          },
          agency_activities: {
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
      ).except(:override))
    end
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
    row_number = 0

    CSV.parse(file, headers: true) do |row|
      row_number += 1

      if row[1].nil? || row[1].blank?
        error = { row: row_number, message: ['Name is empty'] }
        errors << error
        next
      end

      if row[2].nil? || row[2].blank?
        error = { row: row_number, message: ['Type is empty'] }
        errors << error
        next
      end

      row[2].downcase!
      if ['agency', 'advertiser'].include? row[2]
        if row[2] == 'advertiser'
          type_id = self.advertiser_type_id(current_user.company)
        else
          type_id = self.agency_type_id(current_user.company)
        end
      else
        error = { row: row_number, message: ['Type is invalid. Use "Agency" or "Advertiser" string'] }
        errors << error
        next
      end

      if row[3].present?
        parent = Client.where("company_id = ? and name ilike ?", current_user.company_id, row[3].strip.downcase).first
        unless parent
          error = { row: row_number, message: ["Parent account #{row[3]} could not be found"] }
          errors << error
          next
        end
      else
        parent = nil
      end

      if row[4].present? && row[2] == 'advertiser'
        category_field = current_user.company.fields.where(name: 'Category').first
        category = category_field.options.where('name ilike ?', row[4]).first
        unless category
          error = { row: row_number, message: ["Category #{row[4]} could not be found"] }
          errors << error
          next
        end
      else
        category = nil
      end

      if row[5].present? && row[2] == 'advertiser'
        subcategory = category.suboptions.where('name ilike ?', row[5]).first
        unless subcategory
          error = { row: row_number, message: ["Subcategory #{row[5]} could not be found"] }
          errors << error
          next
        end
      else
        subcategory = nil
      end

      client_member_list = []
      if row[13].present?
        members = row[13].split(';').map{|el| el.split('/') }

        client_member_list_error = false

        members.each do |member|
          if member[1].nil?
            error = { row: row_number, message: [ "Account team member #{member[0]} does not have share" ] }
            errors << error
            client_member_list_error = true
            break
          elsif user = current_user.company.users.where('email ilike ?', member[0]).first
            client_member_list << user
          else
            error = { row: row_number, message: ["Account team member #{member[0]} could not be found in the users list"] }
            errors << error
            client_member_list_error = true
            break
          end
        end

        if client_member_list_error
          next
        end
      end

      address_params = {
        street1: row[6].nil? ? nil : row[6].strip,
        city: row[7].nil? ? nil : row[7].strip,
        state: row[8].nil? ? nil : row[8].strip,
        zip: row[9].nil? ? nil : row[9].strip,
        phone: row[10].nil? ? nil : row[10].strip,
      }

      client_params = {
        name: row[1].strip,
        website: row[11].nil? ? nil : row[11].strip,
        client_type_id: type_id,
        client_category: category,
        client_subcategory: subcategory,
        parent_client: parent
      }

      type_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: current_user.company.fields.where(name: 'Client Type').first.id,
        option_id: type_id,
        company_id: current_user.company.id
      }

      category_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: current_user.company.fields.where(name: 'Category').first.id,
        option_id: (category ? category.id : nil),
        company_id: current_user.company.id
      }

      if row[0]
        begin
          client = current_user.company.clients.find(row[0])
        rescue ActiveRecord::RecordNotFound
        end
      end

      unless client.present?
        clients = current_user.company.clients.where('name ilike ?', row[1].strip.downcase)
        if clients.length > 1
          error = { row: row_number, message: ["Account name #{row[1]} matched more than one account record"] }
          errors << error
          next
        end
        client = clients.first
      end

      if client.present?
        if parent && parent.id == client.id
          error = { row: row_number, message: ["Accounts can't be parents of themselves"] }
          errors << error
          next
        end

        address_params[:id] = client.address.id if client.address
        client_params[:id] = client.id
        type_value_params[:subject_id] = client.id
        category_value_params[:subject_id] = client.id

        if client_type_field = client.values.where(field_id: type_value_params[:field_id]).first
          type_value_params[:id] = client_type_field.id
        end

        if client_category_field = client.values.where(field_id: category_value_params[:field_id]).first
          category_value_params[:id] = client.values.where(field_id: category_value_params[:field_id]).first.id
        end
      else
        client = current_user.company.clients.create(name: row[1].strip)
        client.update_attributes(created_by: current_user.id)
      end

      client_params[:address_attributes] = address_params
      client_params[:values_attributes] = [type_value_params, category_value_params]

      if client.update_attributes(client_params)
        client.client_members.delete_all if row[12] == 'Y'
        client_member_list.each_with_index do |user, index|
          client_member = client.client_members.find_or_initialize_by(user: user)
          client_member.update(share: members[index][1].to_i)
        end
      else
        error = { row: row_number, message: client.errors.full_messages }
        errors << error
        next
      end
    end
    errors
  end

  def self.client_type_field(company)
    company.fields.where(name: 'Client Type').first
  end

  def self.agency_type_id(company)
    client_type_field(company).options.where(name: "Agency").first.id
  end

  def self.advertiser_type_id(company)
    client_type_field(company).options.where(name: "Advertiser").first.id
  end

  def global_type_id
    if self.client_type_id
      if self.client_type_id == Client.advertiser_type_id(company)
        Client::ADVERTISER
      elsif self.client_type_id == Client.agency_type_id(company)
        Client::AGENCY
      end
    end
  end

  def advertiser_last_deal
    advertiser_deals.order('created_at desc').limit(1).first.created_at
  end

  def agency_last_deal
    agency_deals.order('created_at desc').limit(1).first.created_at
  end

  def advertiser_win_rate
    return 0 if (advertiser_deals.won.count + advertiser_deals.lost.count).zero?

    (advertiser_deals.won.count.to_f / (advertiser_deals.won.count + advertiser_deals.lost.count).to_f * 100).to_i
  end

  def agency_win_rate
    return 0 if (agency_deals.won.count + agency_deals.lost.count).zero?

    (agency_deals.won.count.to_f / (agency_deals.won.count + agency_deals.lost.count).to_f * 100).to_i
  end
end
