class ContentFee < ActiveRecord::Base
  belongs_to :io
  belongs_to :product
  has_many :influencer_content_fees, dependent: :destroy

  has_many :content_fee_product_budgets, dependent: :destroy

  has_one :request, as: :requestable, dependent: :destroy

  validate :active_exchange_rate

  accepts_nested_attributes_for :content_fee_product_budgets

  default_scope { order(:created_at) }
  scope :for_product_id, -> (product_id) { where("product_id = ?", product_id) }
  scope :for_product_ids, -> (product_ids) { where("product_id in (?)", product_ids) }
  scope :for_time_period, -> (start_date, end_date) { where('content_fees.start_date <= ? AND content_fees.end_date >= ?', end_date, start_date) }
  
  after_update do
    if content_fee_product_budgets.sum(:budget) != budget || content_fee_product_budgets.sum(:budget_loc) != budget_loc
      if budget_changed? || budget_loc_changed?
        self.update_content_fee_product_budgets
      else
        self.update_budget
      end
      io.update_total_budget
    end
  end

  after_create do
    # create_content_fee_product_budgets
    io.update_total_budget
  end

  def active_exchange_rate
    if io.curr_cd != 'USD'
      unless io.exchange_rate
        errors.add(:curr_cd, "does not have an exchange rate for #{io.curr_cd} at #{io.created_at.strftime("%m/%d/%Y")}")
      end
    end
  end

  def create_content_fee_product_budgets
    deal_product = content_fee_deal_product
    if deal_product && deal_product.deal_product_budgets.length == io.months.length
      deal_product.deal_product_budgets.order("start_date asc").each_with_index do |monthly_budget, index|
        content_fee_product_budgets.create(
          start_date: monthly_budget.start_date,
          end_date: monthly_budget.end_date,
          budget: monthly_budget.budget,
          budget_loc: monthly_budget.budget_loc
        )
      end
    else
      generate_content_fee_product_budgets
    end
  end

  def generate_content_fee_product_budgets
    last_index = io.months.count - 1
    total = 0
    total_loc = 0

    io_start_date = io.start_date
    io_end_date = io.end_date
    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * io.days_per_month[index]).round(0)
        total += monthly_budget

        monthly_budget_loc = (daily_budget_loc * io.days_per_month[index]).round(0)
        total_loc += monthly_budget_loc
      end

      period = Date.new(*month)
      content_fee_product_budgets.create(
        start_date: [period, io_start_date].max,
        end_date: [period.end_of_month, io_end_date].min,
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end

  def content_fee_deal_product
    if io && product
      io.deal.deal_products.find_by(product: product)
    else
      nil
    end
  end

  def daily_budget
    budget / (io.end_date - io.start_date + 1)
  end

  def daily_budget_loc
    budget_loc / (io.end_date - io.start_date + 1)
  end

  def update_content_fee_product_budgets
    last_index = content_fee_product_budgets.count - 1
    total = 0.0
    total_loc = 0.0

    content_fee_product_budgets.order("start_date asc").each_with_index do |content_fee_product_budget, index|
      if last_index == index
        monthly_budget = (budget) - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * io.days_per_month[index]).round(2)
        total += monthly_budget

        monthly_budget_loc = (daily_budget_loc * io.days_per_month[index]).round(2)
        total_loc += monthly_budget_loc
      end
      content_fee_product_budget.update(
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
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
    self.update(budget: new_budget, budget_loc: new_budget_loc)
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
