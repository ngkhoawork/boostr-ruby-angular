class Product < ActiveRecord::Base
  belongs_to :company
  belongs_to :product_family
  belongs_to :option1, class_name: 'ProductOption'
  belongs_to :option2, class_name: 'ProductOption'
  has_many :deal_products
  has_many :values, as: :subject
  has_many :ad_units

  validates :margin,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 100
    },
    allow_nil: true
  validates :name, 
    uniqueness: { 
      scope: [:option1_id, :option2_id, :company_id], 
      message: 'has already been taken with current options' 
    },
    presence: true
  validates :revenue_type, presence: true

  REVENUE_TYPES = %w('Display', 'Content-Fee', 'None')

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  scope :active, -> { joins('LEFT JOIN product_families ON products.product_family_id = product_families.id').where('products.active IS true AND (product_families.active IS true OR products.product_family_id IS NULL)') }
  scope :by_revenue_type, -> (revenue_type) { where('revenue_type = ?', revenue_type) if revenue_type }
  scope :by_product_family, -> (product_family_id) { where('product_family_id = ?', product_family_id) if product_family_id }

  after_create do
    create_dimension
    update_forecast_fact_callback
  end

  after_destroy do |product_record|
    delete_dimension(product_record)
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
    ForecastPipelineCalculatorWorker.peto_csvrform_async(deal_change)
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
        company&.product_option1, 
        company&.product_option2, 
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
          product.option1&.name,
          product.option2&.name,
          get_option_value(product, "Pricing Type"),
          product.revenue_type,
          product.margin,
          product.active ? "Yes" : "No",
          product.is_influencer_product ? "Yes" : "No"
        ]
      end
    end
  end

end
