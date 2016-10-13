class DealProduct < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :product
  has_many :deal_product_budgets, dependent: :destroy

  validates :product, presence: true

  accepts_nested_attributes_for :deal_product_budgets

  before_update :multiply_budget
  before_create :multiply_budget

  after_update do
    if deal_product_budgets.sum(:budget) != budget
      if budget_changed?
        self.update_product_budgets
      else
        self.update_budget
      end
    end
    deal.update_total_budget
  end

  after_create do
    deal.update_total_budget
  end

  def multiply_budget
    self.budget = budget * 100 if budget_changed?
  end

  def daily_budget
    (budget / 100.0) / (deal.end_date - deal.start_date + 1).to_i
  end

  def create_product_budgets
    last_index = deal.months.count - 1
    total = 0

    deal.months.each_with_index do |month, index|
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
    self.update(budget: deal_product_budgets.sum(:budget) / 100)
  end
end
