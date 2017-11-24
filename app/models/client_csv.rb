class ClientCsv
  include ActiveModel::Validations

  CLIENT_TYPES = %(agency advertiser).freeze

  attr_accessor :name, :type, :parent_account, :company_id,
                :category, :subcategory, :teammembers, :region,
                :segment, :holding_company

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

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    # set_company_fields
  end

  def perform
    return self.errors.full_messages unless self.valid?
  end

  private

  def client_type
    @_client_type ||= type&.downcase
  end

  def client_category
    @_client_category ||= category_field.option_from_name(category)
  end

  def client_subcategory
    @_client_subcategory ||= client_category.suboptions.find_by('name ilike ?', subcategory)
  end

  def client_region
    @_client_region ||= region_field.option_from_name(region)
  end

  def client_segment
    @_client_segment ||= segment_field.option_from_name(segment)
  end

  def client_holding_company
    @_client_holding_company ||= HoldingCompany.where("name ilike ?", holding_company).first
  end

  def correct_client_type
    if client_type.present? && !(CLIENT_TYPES.include? client_type)
      errors.add(:type, 'is invalid. Use "Agency" or "Advertiser" string')
    end
  end

  def parent_client_exists
    return unless parent_account.present?
    parent = Client.where(
      "company_id = ? and name ilike ?", company_id, parent_account
    ).exists?
    if !parent
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
      members = teammembers&.split(';')&.map{|el| el.split('/')}

      members.each do |member|
        if member[1].nil?
          errors.add(:teammember, "#{member[0]} does not have a share value")
        end
      end
    end
  end

  def client_member_users_exist
    if teammembers.present?
      members = teammembers&.split(';')&.map{|el| el.split('/')}

      members.each do |member|
        user = company.users.where('email ilike ?', member[0]).first
        if user.nil?
          errors.add(:teammember, "#{member[0]} could not be found in the users list")
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

  # def set_company_fields
  #   unless self.class.class_variable_defined?(:@@type_field)
  #     self.class.class_variable_set(:@@type_field, type_field)
  #   end

  #   unless self.class.class_variable_defined?(:@@category_field)
  #     self.class.class_variable_set(:@@category_field, category_field)
  #   end

  #   unless self.class.class_variable_defined?(:@@region_field)
  #     self.class.class_variable_set(:@@region_field, region_field)
  #   end

  #   unless self.class.class_variable_defined?(:@@segment_field)
  #     self.class.class_variable_set(:@@segment_field, segment_field)
  #   end
  # end

  # def type_field
  #   Field.find_by(
  #     company_id: company_id, subject_type: 'Client', name: 'Client Type'
  #   )
  # end

  def category_field
    if self.class.class_variable_defined?(:@@category_field)
      self.class.class_variable_get(:@@category_field)
    else
      self.class.class_variable_set(
        :@@category_field,
        Field.find_by(
          company_id: company_id, subject_type: 'Client', name: 'Category'
        )
      )
    end
  end

  def region_field
    if self.class.class_variable_defined?(:@@region_field)
      self.class.class_variable_get(:@@region_field)
    else
      self.class.class_variable_set(
        :@@region_field,
        Field.find_by(
          company_id: company_id, subject_type: 'Client', name: 'Region'
        )
      )
    end
  end

  def segment_field
    if self.class.class_variable_defined?(:@@segment_field)
      self.class.class_variable_get(:@@segment_field)
    else
      self.class.class_variable_set(
        :@@segment_field,
        Field.find_by(
          company_id: company_id, subject_type: 'Client', name: 'Segment'
        )
      )
    end
  end

  def company
    @_company ||= Company.find(company_id)
  end
end
