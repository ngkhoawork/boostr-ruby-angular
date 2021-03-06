class Product < ActiveRecord::Base
  SAFE_COLUMNS = %i{full_name name product_line revenue_type}

  belongs_to :company
  belongs_to :product_family
  belongs_to :parent, class_name: 'Product', inverse_of: :children
  belongs_to :top_parent, class_name: 'Product'

  has_many :deal_products
  has_many :values, as: :subject
  has_many :ad_units
  has_many :children, class_name: 'Product', foreign_key: 'parent_id', inverse_of: :parent 
  has_many :quotas, as: :product
  has_many :pmp_items
  has_many :costs
  has_many :leads, dependent: :nullify

  validates :margin,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 99
    },
    allow_nil: true
  validates :name, 
    uniqueness: { 
      scope: [:parent_id, :company_id], 
      message: 'Name has already been taken' 
    },
    presence: true
  validates :revenue_type, presence: true
  validate :check_recursive_parent_id
  validate :check_self_as_parent
  validate :check_level

  REVENUE_TYPES = %w('Display', 'Content-Fee', 'PMP', 'None')

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  scope :active, -> do
    joins('LEFT JOIN product_families ON products.product_family_id = product_families.id')
    .where('products.active IS true AND (product_families.active IS true OR products.product_family_id IS NULL)')
  end
  scope :by_revenue_type, -> (revenue_type) { where('revenue_type = ?', revenue_type) if revenue_type }
  scope :by_product_family, -> (product_family_id) { where('product_family_id = ?', product_family_id) if product_family_id }
  scope :by_level, -> (level) { where(level: level) unless level.nil? }
  scope :by_name, -> (name) { where('name ilike ?', "%#{name}%") }

  before_save do
    set_top_parent
    set_level
  end

  after_create do
    create_dimension
  end

  after_update do
    update_children
    update_cost
  end

  after_destroy do |product_record|
    delete_dimension(product_record)
  end

  def update_cost
    ProductMarginUpdateWorker.perform_async(id, margin, margin_was) if margin_changed?
  end

  def create_dimension
    ProductDimension.create(
      id: self.id,
      company_id: self.company_id,
      name: self.name,
      revenue_type: self.revenue_type
    )
  end

  def delete_dimension(product_record)
    ProductDimension.destroy(product_record.id)
    ForecastPipelineFact.destroy_all(product_dimension_id: product_record.id)
    ForecastRevenueFact.destroy_all(product_dimension_id: product_record.id)
    ForecastPmpRevenueFact.destroy_all(product_dimension_id: product_record.id)
    ForecastCostFact.destroy_all(product_dimension_id: product_record.id)
  end

  def as_json(options = {})
    super(options.merge(
      include: [
        :ad_units, 
        :parent,
        :top_parent,
        values: { 
          include: [:option], 
          methods: [:value] 
        }
      ],
      methods: [
        :level0,
        :level1,
        :level2
      ]
    ))
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def self.get_option_value(subject, field_name)
    if !subject.nil?
      subject_fields = subject.fields
      if !subject_fields.nil?
        field = subject_fields.find_by_name(field_name)
        value = subject.values.find_by_field_id(field.id) if !field.nil?
        option = value.option.name if !value.nil? && !value.option.nil?
      end
     end
    return option
  end

  def self.to_csv(company)
    CSV.generate do |csv|
      csv << [
        "Product ID", 
        "Product Name", 
        "Full Name",
        "Product Family", 
        "Parent Product",
        "Level",
        "Pricing Type", 
        "Revenue Type", 
        "Margin", 
        "Active",
        "Is Influencer Product"
      ]
      all.each do |product|
        csv << [
          product.id,
          product.name,
          product.full_name,
          product.product_family&.name,
          product&.parent&.name,
          product.level,
          get_option_value(product, "Pricing Type"),
          product.revenue_type,
          product.margin,
          product.active ? "Yes" : "No",
          product.is_influencer_product ? "Yes" : "No"
        ]
      end
    end
  end

  def self.include_children(products)
    products.map(&:include_children).flatten.uniq
  end

  def all_children(children_array = [])
    children_array += children.all
    children.each do |child|
      children_array = child.all_children(children_array)
    end
    children_array
  end

  def include_children
    [self] + all_children
  end

  def generate_full_name
    if parent.present?
      parent.generate_full_name() + ' ' + name
    else
      name
    end
  end

  def calculate_level
    if parent_id.nil?
      0
    elsif parent_id == top_parent_id
      1
    else
      2
    end
  end

  def level0
    if level == 0
      id_name_hash(self)
    else
      id_name_hash(top_parent)
    end
  end

  def level1
    if level == 1
      id_name_hash(self)
    elsif level == 2
      id_name_hash(parent)
    else
      {}
    end
  end

  def level2
    if level == 2
      id_name_hash(self)
    else
      {}
    end
  end

  private

  def id_name_hash(obj)
    obj.serializable_hash(only: [:id, :name]) rescue {}
  end

  def set_top_parent
    if parent_id.present?
      self.top_parent_id = parent.top_parent_id || parent_id 
    else
      self.top_parent_id = nil
    end
  end

  def set_level
    self.level = calculate_level
  end

  def update_children
    parent_full_name = full_name
    children.each do |child|
      child.full_name = parent_full_name + ' ' + child.name
      child.save
    end
  end

  def check_recursive_parent_id
    if parent_id.present?
      ids = [id].compact
      depth = parent.level + 1
      while ids.present? 
        ids = company.products.where(parent_id: ids).pluck(:id)
        depth += 1 if ids.present?
        if ids.include?(parent_id)
          errors.add(:base, "You can't select child product as parent.") and break
        elsif depth > 2
          errors.add(:base, "Product level should be less than equal to 2. Please consider level of child products.") and break
        end
      end
    end
  end

  def check_self_as_parent
    if parent_id.present? && parent_id == id
      errors.add(:parent_product, "can't be self")
    end
  end

  def check_level
    if self.parent&.calculate_level == 2
      errors.add(:base, "Product level should be less than equal to 2. Please consider level of parent product.")
    end
  end
end
