class Product < ActiveRecord::Base
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

  REVENUE_TYPES = %w('Display', 'Content-Fee', 'PMP', 'None')

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  scope :active, -> { joins('LEFT JOIN product_families ON products.product_family_id = product_families.id').where('products.active IS true AND (product_families.active IS true OR products.product_family_id IS NULL)') }
  scope :by_revenue_type, -> (revenue_type) { where('revenue_type = ?', revenue_type) if revenue_type }
  scope :by_product_family, -> (product_family_id) { where('product_family_id = ?', product_family_id) if product_family_id }

  before_update do
    set_top_parent
    set_level
  end

  after_update :update_top_parent_on_children

  after_create do
    create_dimension
    update_forecast_fact_callback
  end

  after_update do
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
  end

  def update_forecast_fact_callback
    time_period_ids = company.time_periods.collect{|time_period| time_period.id}
    user_ids = company.users.collect{|user| user.id}
    product_ids = [self.id]
    stage_ids = company.stages.collect{|stage| stage.id}
    io_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids}
    deal_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids, stage_ids: stage_ids}
    ForecastRevenueCalculatorWorker.perform_async(io_change)
    ForecastPipelineCalculatorWorker.perform_async(deal_change)
  end

  def as_json(options = {})
    super(options.merge(include: [:ad_units, values: { include: [:option], methods: [:value] }]))
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

  private

  def set_top_parent
    if parent.present?
      self.top_parent_id = parent.top_parent_id || parent.id 
    else
      self.top_parent_id = nil
    end
  end

  def set_level
    if parent.nil?
      self.level = 0
    elsif parent_id == top_parent_id
      self.level = 1
    else
      self.level = 2
    end
  end

  def update_top_parent_on_children
    if top_parent_id_changed?
      children.each do |child|
        child.update_attributes(top_parent_id: top_parent_id || id)
      end
    end
  end

  def check_recursive_parent_id
    if parent_id.present?
      ids = [id].compact
      while ids.present? 
        ids = company.products.where(parent_id: ids).pluck(:id)
        errors.add(:parent_product, "You can't select child product as parent") and break if ids.include?(parent_id)
      end
    end
  end

  def check_self_as_parent
    if parent_id.present? && parent_id == id
      errors.add(:parent_product, "You can't select current product as parent")
    end
  end
end