class Csv::IoCost
  include ActiveModel::Validations

  attr_accessor :io_number, :cost_id, :product_id, :product_name, :type, :month, :amount, :company_id, :imported_costs

  validates_presence_of :io_number, :product_name, :month, :amount, :company_id
  validates_numericality_of :amount
  validate :validate_product_existence
  validate :validate_io_existence
  validate :validate_type_existence
  validate :validate_month_format

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    cost.product = product
    cost.is_estimated = false if cost.id
    cost.save!

    cost_monthly_amount.budget = amount / io.exchange_rate
    cost_monthly_amount.budget_loc = amount
    cost_monthly_amount.save!

    value.option = option
    value.save!
  end

  def cost
    if cost_id.present?
      @_cost ||= Cost.find_by(id: cost_id, io: io)
    else
      @_cost ||= imported_costs.uniq.find {|cost| cost.io == io && cost.product == product && cost.values.find_by(field: field, option: option).present?}
    end
    @_cost ||= Cost.new(io: io, product: product, budget: 0, budget_loc: 0)
  end

  private

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end

  def option
    @_option ||= field.options.find_by(name: type)
  end

  def value
    @_value ||= cost.values.find_or_initialize_by(field: field)
  end

  def io
    @_io ||= company&.ios&.find_by(io_number: io_number)
  end

  def product
    if product_id.present?
      @_product ||= company&.products&.find_by(id: product_id, name: product_name, active: true)
    else
      @_product ||= company&.products&.find_by(name: product_name, active: true)
    end
  end

  def company
    @_company ||= Company.where(id: company_id).first
  end

  def cost_monthly_amount
    @_cost_monthly_amount ||= cost&.cost_monthly_amounts&.find_or_initialize_by(start_date: start_date, end_date: end_date)
  end

  def start_date
    [Date.strptime(month, '%m/%Y'), io.start_date].max
  end

  def end_date
    [start_date.end_of_month, io.end_date].min
  end

  def validate_month_format
    Date.strptime(month, '%m/%Y')
  rescue
    errors.add(:base, "Month --#{month}-- does not match mm/yyyy format")
  end

  def validate_type_existence
    if type.present? && option.nil?
      errors.add(:base, "Cost type with --#{type}-- doesn't exist")
    end
  end

  def validate_product_existence
    if product.nil? && product_id.present?
      errors.add(:base, "Product with --#{product_id}-- ID and --#{product_name}-- name doesn't exist")
    elsif product.nil?
      errors.add(:base, "Product with --#{product_name}-- name doesn't exist")
    end
  end

  def validate_io_existence
    if io.nil?
      errors.add(:base, "IO with --#{io_number}-- number doesn't exist")
    end
  end
end