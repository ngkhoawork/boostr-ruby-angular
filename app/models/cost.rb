class Cost < ActiveRecord::Base
  belongs_to :io
  belongs_to :product
  has_many :values, as: :subject
  has_many :cost_monthly_amounts, dependent: :destroy

  validate :active_exchange_rate

  delegate :company, to: :io

  accepts_nested_attributes_for :cost_monthly_amounts
  accepts_nested_attributes_for :values

  scope :estimated, -> { where('is_estimated IS true') }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) }

  after_create do
    generate_cost_monthly_amounts if cost_monthly_amounts.count == 0
  end

  after_destroy do
    update_revenue_budget
  end

  after_update do
    update_cost_or_monthly_budget
  end

  set_callback :save, :after, :update_revenue_fact_callback

  def update_revenue_fact_callback
    update_revenue_budget if budget_changed? || budget_loc_changed?
    if product_id_changed?
      if product_id_was.present?
        old_product = Product.find(product_id_was)
        update_revenue_product(old_product) if old_product.present?
      end
      update_revenue_product(product)
    end
  end

  def update_revenue_product(product)
    if io.present? && product.present?
      time_periods = company.time_periods.for_time_period(io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          ForecastCostFactCalculator::Calculator.new(time_period, user, product).calculate()
        end
      end
    end
  end

  def update_revenue_budget
    if io.present? && product.present?
      time_periods = company.time_periods.for_time_period(io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          ForecastCostFactCalculator::Calculator.new(time_period, user, product).calculate()
        end
      end
    end
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def company
    io.company
  end

  def update_budget
    new_budget = cost_monthly_amounts.sum(:budget)
    new_budget_loc = cost_monthly_amounts.sum(:budget_loc)
    update(budget: new_budget, budget_loc: new_budget_loc, is_estimated: false)
  end

  def daily_budget
    budget / (io.end_date - io.start_date + 1)
  end

  def daily_budget_loc
    budget_loc / (io.end_date - io.start_date + 1)
  end

  def active_exchange_rate
    if io.curr_cd != 'USD' && !io.exchange_rate
      errors.add(
        :curr_cd,
        "does not have an exchange rate for #{io.curr_cd} at #{io.created_at.strftime("%m/%d/%Y")}"
      )
    end
  end

  def generate_cost_monthly_amounts
    Cost::AmountsGenerateService.new(self).perform
  end

  def update_cost_monthly_amounts
    Cost::AmountsUpdateService.new(self).perform
  end

  def update_periods
    cost_monthly_amounts.each.with_index do |cost_monthly_amount, index|
      period = Date.new(*io.months[index])
      cost_monthly_amount.start_date = [period, io.start_date].max
      cost_monthly_amount.end_date = [period.end_of_month, io.end_date].min
    end
  end

  def update_cost_or_monthly_budget
    if cost_monthly_amounts.sum(:budget) != budget || cost_monthly_amounts.sum(:budget_loc) != budget_loc
      if budget_changed? || budget_loc_changed?
        update_cost_monthly_amounts
        update(is_estimated: false)
      else
        update_budget
      end
    end
  end
end
