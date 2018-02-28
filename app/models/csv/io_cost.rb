class Csv::IoCost
  include ActiveModel::Validations

  attr_accessor :io_number, :product_name, :type, :month, :amount, :company_id

  validates_presence_of :io_number, :product_name, :month, :amount, :company_id
  validates_numericality_of :amount
  validates_inclusion_of :month, in: Date::ABBR_MONTHNAMES
  validate :validate_product_existence
  validate :validate_io_existence
  validate :validate_type_existence

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    cost.is_estimated = false if cost.id
    cost.budget = amount / io.exchange_rate
    cost.budget_loc = amount
    cost.save!

    value.option = option
    value.save!
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
    @_product ||= company&.products&.find_by(name: product_name, active: true)
  end

  def company
    @_company ||= Company.where(id: company_id).first
  end

  def cost
    @_cost ||= Cost.find_or_initialize_by(
      product: product,
      io: io,
      start_date: start_date,
      end_date: end_date
    )
  end

  def start_date
    Date.new(Date.current.in_time_zone('Pacific Time (US & Canada)').year, Date::ABBR_MONTHNAMES.index(month), 1)
  end

  def end_date
    start_date.end_of_month
  end

  def validate_type_existence
    if type.present? && option.nil?
      errors.add(:base, "Cost type with --#{type}-- name doesn't exist")
    end
  end

  def validate_product_existence
    if product.nil?
      errors.add(:base, "Product with --#{product_name}-- name doesn't exist")
    end
  end

  def validate_io_existence
    if io.nil?
      errors.add(:base, "IO with --#{io_number}-- number doesn't exist")
    end
  end
end