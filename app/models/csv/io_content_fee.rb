class Csv::IoContentFee
  include ActiveModel::Validations
  include Csv::ProductOptionable

  attr_accessor :io_number, 
                :product_name, 
                :product_level1, 
                :product_level2, 
                :budget, 
                :start_date, 
                :end_date, 
                :company_id

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
    content_fee_product_budget.start_date = formatted_start_date
    content_fee_product_budget.end_date = formatted_end_date
    content_fee_product_budget.budget = budget
    content_fee_product_budget.budget_loc = budget / io.exchange_rate
    content_fee_product_budget.save!
  end

  def io
    @_io ||= company&.ios&.find_by(io_number: io_number)
  end

  def content_fee
    @_content_fee ||= ContentFee.create_with(budget: 0).find_or_create_by(io: io, product: product)
  end

  private

  def product
    @_product ||= company&.products&.find_by(full_name: product_full_name, revenue_type: 'Content-Fee', active: true)
  end

  def company
    @_company ||= Company.where(id: company_id).first
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= find_content_fee_product_budget() || ContentFeeProductBudget.new(
        content_fee: content_fee,
        start_date: formatted_date(start_date),
        end_date: formatted_date(end_date)
      )
  end

  def find_content_fee_product_budget
    ContentFeeProductBudget.where(
      content_fee: content_fee
    ).where(
      "date_part('year', start_date) = ? and date_part('month', start_date) = ?",
      formatted_start_date.year,
      formatted_start_date.month
    ).where(
      "date_part('year', end_date) = ? and date_part('month', end_date) = ?",
      formatted_end_date.year,
      formatted_end_date.month
    ).first
  end

  def formatted_start_date
    @_formatted_start_date ||= formatted_date(start_date)
  end

  def formatted_end_date
    @_formatted_end_date ||= formatted_date(end_date)
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
      errors.add(:base, "Product with --#{product_full_name}-- name doesn't exist")
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