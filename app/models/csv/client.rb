class Csv::Client
  include ActiveModel::Validations

  CLIENT_TYPES = %(agency advertiser).freeze

  ATTRS = [
    :account_id, :name, :type, :parent_account, :company_id,
    :user_id, :category, :subcategory, :teammembers, :region,
    :segment, :holding_company, :address, :city, :state, :zip,
    :country, :phone, :website, :custom_field_names,
    :replace_team, :unmatched_fields, :company_fields
  ]
  attr_accessor(*ATTRS)

  validates_presence_of :name, :type, :company_id

  validate :correct_client_type
  validate :parent_client_exists
  validate :category_exists
  validate :subcategory_exists
  validate :client_members_have_share
  validate :client_member_users_exist
  validate :region_exists
  validate :segment_exists
  validate :holding_company_exists
  validate :name_matches_one_record
  validate :not_self_parent

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?

    assign_client_attributes

    if client.valid?
      client.save!
      import_client_members
      import_custom_fields
      true
    else
      false
    end
  end

  def object_errors
    client.errors.full_messages
  end

  private

  def assign_client_attributes
    client.assign_attributes(client_import_params)
  end

  def import_client_members
    client.client_members.delete_all if replace_team == 'Y'
    @client_member_list.each_with_index do |user, index|
      client_member = client.client_members.find_or_initialize_by(user: user)
      client_member.update(share: client_members[index][1].to_i)
    end
  end

  def import_custom_fields
    cf_values = {}

    if unmatched_fields.present?
      account_cf_names.each do |cf_name|
        cf_values[cf_name.field_name] = unmatched_fields[cf_name.to_csv_header]
      end
    end

    if cf_values.compact.any?
      client.upsert_custom_fields(cf_values)
    end
  end

  def client
    @client ||= Client.find_by(company_id: company_id, id: account_id) if account_id.present?
    @client ||= client_relation.first
    @client ||= Client.new(company_id: company_id, created_by: user_id)
  end

  def client_members
    if teammembers.present?
      @_client_members = teammembers&.split(';')&.map{|el| el.split('/')}
    end
  end

  def client_import_params
    client_base_params.merge(
      address_attributes: client_address_attributes,
      values_attributes: [
        type_value_params,
        category_value_params,
        region_value_params,
        segment_value_params
      ]
    )
  end

  def client_base_params
    {
      name: name,
      website: website,
      client_type_id: client_type_id,
      client_category: client_category,
      client_subcategory: client_subcategory,
      client_region: client_region,
      client_segment: client_segment,
      parent_client: parent_account_record,
      holding_company: client_holding_company
    }
  end

  def client_address_attributes
    {
      id: client.address&.id,
      street1: address,
      city: city,
      state: state,
      zip: zip,
      country: country,
      phone: phone
    }
  end

  def category_value_params
    {
      id: find_client_value_id(category_field.id),
      subject_id: client.id,
      value_type: 'Option',
      subject_type: 'Client',
      field_id: category_field.id,
      option_id: client_category&.id,
      company_id: company_id
    }
  end

  def region_value_params
    {
      id: find_client_value_id(region_field.id),
      subject_id: client.id,
      value_type: 'Option',
      subject_type: 'Client',
      field_id: region_field.id,
      option_id: client_region&.id,
      company_id: company_id
    }
  end

  def segment_value_params
    {
      id: find_client_value_id(segment_field.id),
      subject_id: client.id,
      value_type: 'Option',
      subject_type: 'Client',
      field_id: segment_field.id,
      option_id: client_segment&.id,
      company_id: company_id
    }
  end

  def type_value_params
    {
      id: find_client_value_id(type_field.id),
      subject_id: client.id,
      value_type: 'Option',
      subject_type: 'Client',
      field_id: type_field.id,
      option_id: client_type_id,
      company_id: company_id
    }
  end

  def find_client_value_id(field_id)
    client.values.find {
      |value| value.field_id == field_id
    }&.id
  end

  def client_type_id
    @_client_type_id ||=
      if client_type == 'advertiser'
        advertiser_type_id
      else
        agency_type_id
      end
  end

  def advertiser_type_id
    company_fields.advertiser_type_id
  end

  def agency_type_id
    company_fields.agency_type_id
  end

  def client_relation
    Client.where(company_id: company_id).where('name ilike ?', name)
  end

  def client_type
    @_client_type ||= type&.downcase
  end

  def client_category
    @_client_category ||= category_field.option_from_name(category) if category.present?
  end

  def client_subcategory
    @_client_subcategory ||= client_category.suboptions.find_by('name ilike ?', subcategory) if client_category.present?
  end

  def client_region
    @_client_region ||= region_field.option_from_name(region) if region.present?
  end

  def client_segment
    @_client_segment ||= segment_field.option_from_name(segment) if segment.present?
  end

  def client_holding_company
    return nil if client_type != 'agency'
    @_client_holding_company ||= HoldingCompany.where("name ilike ?", holding_company).first
  end

  def parent_account_record
    @_parent_account_record ||= Client.find_by(
      "company_id = ? and name ilike ?", company_id, parent_account
    )
  end

  def correct_client_type
    if client_type.present? && !(CLIENT_TYPES.include? client_type)
      errors.add(:type, 'is invalid. Use "Agency" or "Advertiser" string')
    end
  end

  def parent_client_exists
    return unless parent_account.present?

    if parent_account_record.nil?
      errors.add(:parent_account, "#{parent_account} could not be found")
    end
  end

  def category_exists
    if client_type != 'advertiser' || !category.present?
      return
    end

    unless client_category.present?
      errors.add(:category, "#{category} could not be found")
    end
  end

  def subcategory_exists
    if client_type != 'advertiser' || !category.present? || !subcategory.present?
      return
    end

    unless client_subcategory.present?
      errors.add(:subcategory, "#{subcategory} could not be found")
    end
  end

  def client_members_have_share
    if teammembers.present?
      client_members.each do |member|
        if member[1].nil?
          errors.add(:teammember, "#{member[0]} does not have a share value")
        end
      end
    end
  end

  def client_member_users_exist
    @client_member_list = []
    if teammembers.present?
      client_members.each do |member|
        user = User.where(company_id: company_id).where('email ilike ?', member[0]).first
        if user.nil?
          errors.add(:teammember, "#{member[0]} could not be found in the users list")
        else
          @client_member_list << user
        end
      end
    end
  end

  def region_exists
    if region.nil?
      return
    end

    if client_region.nil?
      errors.add(:region, "#{region} could not be found")
    end
  end

  def segment_exists
    if segment.nil?
      return
    end

    if client_segment.nil?
      errors.add(:segment, "#{segment} could not be found")
    end
  end

  def holding_company_exists
    if holding_company.present? && client_type == 'agency'
      if client_holding_company.nil?
        errors.add(:holding_company, "#{holding_company} could not be found")
      end
    end
  end

  def name_matches_one_record
    if !account_id.present? && client_relation.count > 1
      errors.add(:account_name, "#{name} matched more than one account record")
    end
  end

  def not_self_parent
    return if !parent_account.present? || parent_account_record.nil?

    if parent_account_record.id == client.id
      errors.add(:account, "#{name} can't be set as a parent of itself")
    end
  end

  def category_field
    company_fields.category_field
  end

  def region_field
    company_fields.region_field
  end

  def segment_field
    company_fields.segment_field
  end

  def type_field
    company_fields.type_field
  end

  def account_cf_names
    company_fields.account_cf_names
  end
end
