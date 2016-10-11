class DealProduct < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :product
  has_many :deal_product_budgets, dependent: :destroy

  scope :for_time_period, -> (start_date, end_date) { where('deal_product_budgets.start_date <= ? AND deal_product_budgets.end_date >= ?', end_date, start_date) }

  validates :start_date, :end_date, :product, presence: true

  before_update :multiply_budget
  before_create :multiply_budget

  after_update do
    update_product_budgets if deal_product_budgets.sum(:budget) != budget
    deal.update_total_budget
  end

  after_create do
    create_product_budgets
    deal.update_total_budget
  end

  def multiply_budget
    self.budget = budget * 100 if budget_changed?
  end

  def daily_budget
    (budget / 100.0) / (end_date - start_date + 1).to_i
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def create_product_budgets
    last_index = months.count - 1
    total = 0

    months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = (budget / 100.0) - total
      else
        monthly_budget = (daily_budget * deal.days_per_month[index]).round(0)
        total = total + monthly_budget
      end
      period = Date.new(*month)
      deal_product_budgets.create(start_date: period, end_date: period.end_of_month, budget: monthly_budget.round(2))
    end
  end

  def update_product_budgets
    last_index = deal_product_budgets.count - 1
    total = 0
    deal_product_budgets.each_with_index do |deal_product_budget, index|
      if last_index == index
        monthly_budget = (budget / 100.0) - total
      else
        monthly_budget = (daily_budget * deal.days_per_month[index]).round(0)
        total = total + monthly_budget
      end
      deal_product_budget.update(budget: monthly_budget.round(2))
    end
  end

  def update_budget
    self.budget = deal_product_budgets.sum(:budget)
    self.save
  end
end
