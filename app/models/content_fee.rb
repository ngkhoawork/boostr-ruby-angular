class ContentFee < ActiveRecord::Base
  belongs_to :io
  has_many :content_fee_product_budgets, dependent: :destroy
  belongs_to :product

  accepts_nested_attributes_for :content_fee_product_budgets

  after_update do
    if content_fee_product_budgets.sum(:budget) != budget
      if budget_changed?
        self.update_content_fee_product_budgets
      else
        self.update_budget
      end
      io.update_total_budget
    end
  end

  after_create do
    create_content_fee_product_budgets
    io.update_total_budget
  end

  def create_content_fee_product_budgets
    last_index = io.months.count - 1
    total = 0

    io_start_date = io.start_date
    io_end_date = io.end_date
    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = budget - total
      else
        monthly_budget = (daily_budget * io.days_per_month[index]).round(0)
        total = total + monthly_budget
      end

      period = Date.new(*month)
      content_fee_product_budgets.create(start_date: [period, io_start_date].max, end_date: [period.end_of_month, io_end_date].min, budget: monthly_budget.round(2))
    end
  end

  def daily_budget
    budget / (io.end_date - io.start_date + 1).to_i
  end

  def update_content_fee_product_budgets
    last_index = content_fee_product_budgets.count - 1
    total = 0
    content_fee_product_budgets.each_with_index do |content_fee_product_budget, index|
      if last_index == index
        monthly_budget = (budget) - total
      else
        monthly_budget = (daily_budget * io.days_per_month[index]).round(0)
        total = total + monthly_budget
      end
      content_fee_product_budget.update(budget: monthly_budget.round(2))
    end
  end

  def update_budget
    self.update(budget: content_fee_product_budgets.sum(:budget))
  end

  def as_json(options = {})
    super(options.merge(
        include: [
            :content_fee_product_budgets
        ]
      )
    )
  end
end
