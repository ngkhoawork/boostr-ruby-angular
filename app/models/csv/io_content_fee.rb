class Csv::IoContentFee
  include ActiveModel::Validations

  attr_accessor :io_number, :product_name, :budget, :start_date, :end_date, :company_id

  validates_presence_of :io_number, :product_name, :budget, :start_date, :end_date, :company_id
  validates_numericality_of :budget
  validate :validate_product_existence
  validate :validate_io_existence
  validate :validate_start_date_format
  validate :validate_end_date_format
  validate :validate_end_date

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    content_fee_product_budget.update_budget!(budget)
  end

  def io
    @_io ||= company&.ios&.find_by(io_number: io_number)
  end

  def content_fee
    @_content_fee ||= ContentFee.create_with(budget: 0).find_or_create_by(io: io, product: product)
  end

  private

  def product
    @_product ||= company&.products&.find_by(name: product_name, revenue_type: 'Content-Fee', active: true)
  end

  def company
    @_company ||= Company.where(id: company_id).first
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= ContentFeeProductBudget.find_or_initialize_by(
      content_fee: content_fee,
      start_date: formatted_date(start_date),
      end_date: formatted_date(end_date)
    )
  end

  def formatted_date(date)
    Date.strptime(date.gsub(/[-:]/, '/'), '%m/%d/%Y')
  rescue
    raise 'Date format does not match mm/dd/yyyy pattern'
  end

  def validate_start_date_format
    formatted_date(start_date)
  rescue
    errors.add(:base, "Start date does not match mm/dd/yyyy format")
  end

  def validate_end_date_format
    formatted_date(end_date)
  rescue
    errors.add(:base, "End date does not match mm/dd/yyyy format")
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

  def validate_end_date
    date = formatted_date(end_date) rescue nil
    if io.present? && date.present? && date > io.end_date
      errors.add(:base, "Monthly budget end date --#{end_date}-- is greater than IO end date")
    end
  end
end