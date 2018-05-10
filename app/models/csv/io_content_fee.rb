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
  validate :validate_start_date
  validate :validate_end_date
  validate :validate_start_date_before_end_date

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    content_fee_product_budget.update!(
      start_date: formatted_start_date,
      end_date: formatted_end_date,
      budget: budget,
      budget_loc: budget / io.exchange_rate
    )
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
    @_content_fee_product_budget ||= find_content_fee_product_budget || create_content_fee_product_budget
  end

  def create_content_fee_product_budget
    content_fee.content_fee_product_budgets.new(
      start_date: formatted_start_date,
      end_date: formatted_end_date
    )
  end

  def find_content_fee_product_budget
    content_fee.content_fee_product_budgets
               .for_year_month(formatted_start_date)
               .for_end_date_year_month(formatted_end_date)
               .first
  end

  def formatted_start_date
    @_formatted_start_date ||= format_date(start_date)
  end

  def formatted_end_date
    @_formatted_end_date ||= format_date(end_date)
  end

  def format_date(date)
    Date.strptime(date.gsub(/[-:]/, '/'), '%m/%d/%Y')
  rescue
    raise 'Date format does not match mm/dd/yyyy pattern'
  end

  def validate_product_existence
    if product.nil?
      errors.add(:base, I18n.t('csv.errors.io_content_fee.product.existence', product_full_name: product_full_name))
    end
  end

  def validate_io_existence
    if io.nil?
      errors.add(:base, I18n.t('csv.errors.io_content_fee.io.existence', io_number: io_number))
    end
  end

  def validate_end_date
    return unless io.present? && end_date.present? && !date_between_io?(formatted_end_date)
    errors.add(:base, I18n.t('csv.errors.io_content_fee.end_date.not_in_io_range', end_date: end_date))
  rescue
    errors.add(:base, I18n.t('csv.errors.io_content_fee.end_date.invalid', end_date: end_date))
  end

  def validate_start_date
    return unless io.present? && start_date.present? && !date_between_io?(formatted_start_date)
    errors.add(:base, I18n.t('csv.errors.io_content_fee.start_date.not_in_io_range', start_date: start_date))
  rescue
    errors.add(:base, I18n.t('csv.errors.io_content_fee.start_date.invalid', start_date: start_date))
  end

  def validate_start_date_before_end_date
    return unless start_date.present? && end_date.present? && formatted_end_date < formatted_start_date
    errors.add(:base, I18n.t('csv.errors.io_content_fee.start_date.greater_than_end_date', start_date: start_date, end_date: end_date))
  rescue 
    nil
  end

  def date_between_io?(date)
    date.between?(io.start_date, io.end_date)
  end

end
