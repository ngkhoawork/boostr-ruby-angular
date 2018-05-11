class Csv::DealProductBudget
  include ActiveModel::Validations
  include Csv::ProductOptionable

  attr_accessor :deal_id,
                :deal_name,
                :product_name,
                :product_level1,
                :product_level2,
                :budget,
                :start_date,
                :end_date,
                :company_id

  validates_presence_of :deal_name, :product_name, :budget, :start_date, :end_date, :company_id
  validates_numericality_of :budget
  validate :validate_product_existence
  validate :validate_deal_existence
  validate :validate_start_date
  validate :validate_end_date
  validate :validate_start_date_before_end_date

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    deal_product_budget.update!(
      start_date: formatted_start_date,
      end_date: formatted_end_date,
      budget: budget,
      budget_loc: budget / deal.exchange_rate
    )
  end

  def deal
    @_deal ||= if deal_id.present?
      company&.deals&.find_by(id: deal_id)
    else
      company&.deals&.find_by(name: deal_name)
    end
  end

  def deal_product
    @_deal_product ||= DealProduct.create_with(budget: 0).find_or_create_by(deal: deal, product: product)
  end

  private

  def product
    @_product ||= company&.products&.find_by(full_name: product_full_name, active: true)
  end

  def company
    @_company ||= Company.where(id: company_id).first
  end

  def deal_product_budget
    @_deal_product_budget ||= find_deal_product_budget || create_deal_product_budget
  end

  def create_deal_product_budget
    deal_product.deal_product_budgets.new(
      start_date: formatted_start_date,
      end_date: formatted_end_date
    )
  end

  def find_deal_product_budget
    deal_product.deal_product_budgets
               .for_year_month(formatted_start_date)
               .for_end_year_month(formatted_end_date)
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
      errors.add(:base, I18n.t('csv.errors.deal_product_budget.product.existence', product_full_name: product_full_name))
    end
  end

  def validate_deal_existence
    if deal.nil?
      errors.add(:base, I18n.t('csv.errors.deal_product_budget.deal.existence', deal_id: deal_id, deal_name: deal_name))
    end
  end

  def validate_end_date
    return unless deal.present? && end_date.present? && !date_between_deal?(formatted_end_date)
    errors.add(:base, I18n.t('csv.errors.deal_product_budget.end_date.not_in_deal_range', end_date: end_date))
  rescue
    errors.add(:base, I18n.t('csv.errors.deal_product_budget.end_date.invalid', end_date: end_date))
  end

  def validate_start_date
    return unless deal.present? && start_date.present? && !date_between_deal?(formatted_start_date)
    errors.add(:base, I18n.t('csv.errors.deal_product_budget.start_date.not_in_deal_range', start_date: start_date))
  rescue
    errors.add(:base, I18n.t('csv.errors.deal_product_budget.start_date.invalid', start_date: start_date))
  end

  def validate_start_date_before_end_date
    return unless start_date.present? && end_date.present? && formatted_end_date < formatted_start_date
    errors.add(:base, I18n.t('csv.errors.deal_product_budget.start_date.greater_than_end_date', start_date: start_date, end_date: end_date))
  rescue
    nil
  end

  def date_between_deal?(date)
    date.between?(deal.start_date, deal.end_date)
  end

end
