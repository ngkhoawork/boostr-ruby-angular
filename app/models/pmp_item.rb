class PmpItem < ActiveRecord::Base  
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true
  belongs_to :product

  attr_accessor :skip_callback

  has_many :pmp_item_daily_actuals, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  enum pmp_type: ::PMP_TYPES

  validates :ssp_deal_id, :budget, :budget_loc, presence: true

  scope :by_stopped, -> (is_stopped) { where(is_stopped: is_stopped) }

  delegate :start_date, to: :pmp, prefix: false
  delegate :end_date, to: :pmp, prefix: false

  before_validation :convert_currency
  before_save :set_budget_remaining_and_delivered

  after_save do
    update_pmp_budgets if budgets_changed?
    unless skip_callback
      if product_id_changed?
        update_revenue_fact([product, product_was])
      elsif pmp_type_changed? || budgets_changed?
        update_revenue_fact
      end
    end
  end

  after_destroy do
    update_pmp_budgets
    update_revenue_fact
  end

  def update_revenue_fact(products=[product])
    Forecast::PmpRevenueCalcTriggerService.new(pmp, 'product', { products: products.compact }).perform
  end

  def self.calculate(ids)
    PmpItem.where(id: ids).find_each do |pmp_item|
      pmp_item.calculate!
    end
  end

  def calculate!
    calculate_budgets!
    calculate_run_rates!
    update_stopped_status!
    self.save!
  end

  def calculate_run_rates!
    self.run_rate_7_days = run_rate(7)
    self.run_rate_30_days = run_rate(30)
  end

  def calculate_budgets!
    self.budget_delivered = pmp_item_daily_actuals.sum(:revenue)
    self.budget_delivered_loc = pmp_item_daily_actuals.sum(:revenue_loc)
    self.budget_remaining = [budget - budget_delivered, 0].max
    self.budget_remaining_loc = [budget_loc - budget_delivered_loc, 0].max
  end

  def calculate_end_date!
    if daily_actual_end_date.present? && end_date < daily_actual_end_date
      self.end_date = daily_actual_end_date
    end
  end

  def update_stopped_status!
    return if !daily_actual_end_date
    if pmp.opened? && is_stopped == true && daily_actual_end_date >= Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
      self.is_stopped = false
      self.stopped_at = nil
    elsif pmp.opened? && is_stopped == false && daily_actual_end_date < Time.now.in_time_zone('Pacific Time (US & Canada)').to_date - 1.day
      self.is_stopped = true
      self.stopped_at = daily_actual_end_date + 1.day
    end
  end

  def run_rate(days)
    if pmp_item_daily_actuals.count >= days
      pmp_item_daily_actuals.latest.limit(days).to_a.sum(&:revenue_loc) / days
    else
      nil
    end
  end

  def daily_actual_end_date
    pmp_item_daily_actuals.maximum(:date)
  end

  private

  def convert_currency
    if budget_loc.present? && budget_loc_changed?
      self.budget = budget_loc * pmp.exchange_rate
    end
  end

  def set_budget_remaining_and_delivered
    self.budget_delivered ||= 0
    self.budget_delivered_loc ||= 0
    self.budget_remaining = [budget - budget_delivered, 0].max
    self.budget_remaining_loc = [budget_loc - budget_delivered_loc, 0].max
  end

  def update_pmp_budgets
    pmp.calculate_budgets!
  end

  def budgets_changed?
    budget_loc_changed? || budget_changed? || budget_remaining_changed? || budget_remaining_loc_changed? || budget_delivered_changed? || budget_delivered_loc_changed?
  end

  def product_was
    Product.find(product_id_was) if product_id_was
  end
end
