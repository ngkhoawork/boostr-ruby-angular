class ContentFee < ActiveRecord::Base
  include HasCustomField

  belongs_to :io
  belongs_to :product
  has_many :influencer_content_fees, dependent: :destroy
  has_many :content_fee_product_budgets, dependent: :destroy
  has_one :request, as: :requestable, dependent: :destroy

  delegate :company_id, to: :io, prefix: false

  validate :active_exchange_rate

  accepts_nested_attributes_for :content_fee_product_budgets

  default_scope { order(:created_at) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) if product_id.present? }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) }
  scope :for_time_period, -> (start_date, end_date) {
    where('content_fees.start_date <= ? AND content_fees.end_date >= ?', end_date, start_date)
  }
  
  after_update do
    if content_fee_product_budgets.sum(:budget) != budget || content_fee_product_budgets.sum(:budget_loc) != budget_loc
      if (budget_changed? || budget_loc_changed?) && !io.freezed?
        ContentFee::UpdateBudgetsService.new(self).perform
      else
        update_budget
      end
      io.update_total_budget
    end
  end

  after_create do
    ContentFee::ResetBudgetsService.new(self).perform if content_fee_product_budgets.empty?
    io.update_total_budget
  end

  after_destroy do |content_fee|
    update_revenue_pipeline_budget(content_fee)
  end

  set_callback :save, :after, :update_revenue_fact_callback

  def update_revenue_fact_callback
    update_revenue_pipeline_budget(self) if budget_changed? || budget_loc_changed?
    if product_id_changed?
      if product_id_was.present?
        old_product = Product.find(product_id_was)
        update_revenue_pipeline_product(old_product) if old_product.present?
      end
      update_revenue_pipeline_product(product)
    end
  end

  def update_revenue_pipeline_budget(content_fee)
    io = content_fee.io
    product = content_fee.product
    if io.present? && product.present?
      company = io.company
      time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          ForecastRevenueFactCalculator::Calculator.new(time_period, user, product).calculate
        end
      end
    end
  end

  def update_revenue_pipeline_product(product)
    if io.present? && product.present?
      company = io.company
      time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          ForecastRevenueFactCalculator::Calculator.new(time_period, user, product).calculate
        end
      end
    end
  end

  def active_exchange_rate
    if io.curr_cd != 'USD'
      unless io.exchange_rate
        errors.add(:curr_cd, "does not have an exchange rate for #{io.curr_cd} at #{io.created_at.strftime("%m/%d/%Y")}")
      end
    end
  end

  def daily_budget
    budget.to_f / (io.end_date - io.start_date + 1)
  end

  def daily_budget_loc
    budget_loc.to_f / (io.end_date - io.start_date + 1)
  end

  def update_periods
    content_fee_product_budgets.each_with_index do |content_fee_product_budget, index|
      period = Date.new(*io.months[index])
      content_fee_product_budget.start_date = [period, io.start_date].max
      content_fee_product_budget.end_date = [period.end_of_month, io.end_date].min
    end
  end

  def update_budget
    new_budget = content_fee_product_budgets.sum(:budget)
    new_budget_loc = content_fee_product_budgets.sum(:budget_loc)
    update(
      budget: new_budget,
      budget_loc: new_budget_loc
    )
  end

  def as_json(options = {})
    super(
      options.merge(
        include: [
          :content_fee_product_budgets,
          custom_field: { only: CustomField.allowed_attr_names(company, 'ContentFee') }
        ]
      )
    )
  end
end
