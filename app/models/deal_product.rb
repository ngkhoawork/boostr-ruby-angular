class DealProduct < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :product
  has_many :deal_product_budgets, dependent: :destroy
  has_one :deal_product_cf, dependent: :destroy

  validates :product, presence: true
  validate :active_exchange_rate

  accepts_nested_attributes_for :deal_product_budgets
  accepts_nested_attributes_for :deal_product_cf

  after_create do
    if deal_product_budgets.empty?
      self.create_product_budgets
    end
  end

  after_update do
    if deal_product_budgets.sum(:budget_loc) != budget_loc || deal_product_budgets.sum(:budget) != budget
      if budget_loc_changed? || budget_changed?
        self.update_product_budgets
      else
        self.update_budget
        should_update_deal_budget = true
      end
    end

    if should_update_deal_budget
      deal.update_total_budget
    end
  end

  scope :product_type_of, -> (type) { joins(:product).where("products.revenue_type = ?", type) }
  scope :open, ->  { where('deal_products.open IS true')  }

  def daily_budget
    budget / (deal.end_date - deal.start_date + 1).to_f
  end

  def daily_budget_loc
    budget_loc / (deal.end_date - deal.start_date + 1).to_f
  end

  def local_currency_budget_in_usd
    budget_loc / deal.exchange_rate
  end

  def active_exchange_rate
    if deal && deal.curr_cd != 'USD'
      unless deal.company.active_currencies.include?(deal.curr_cd)
        errors.add(:curr_cd, "#{deal.curr_cd} does not have an active exchange rate")
      end
    end
  end

  def create_product_budgets
    last_index = deal.months.count - 1
    total = 0
    total_loc = 0

    deal_start_date = deal.start_date
    deal_end_date = deal.end_date

    deal.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * deal.days_per_month[index]).round(0)
        monthly_budget = 0 if monthly_budget.between?(0, 1)
        total += monthly_budget

        monthly_budget_loc = (daily_budget_loc * deal.days_per_month[index]).round(0)
        monthly_budget_loc = 0 if monthly_budget_loc.between?(0, 1)
        total_loc += monthly_budget_loc
      end
      period = Date.new(*month)
      deal_product_budgets.create(
        start_date: [period, deal_start_date].max,
        end_date: [period.end_of_month, deal_end_date].min,
        budget: monthly_budget,
        budget_loc: monthly_budget_loc
      )
    end
  end

  def update_product_budgets
    last_index = deal_product_budgets.count - 1
    total = 0
    total_loc = 0

    deal_product_budgets.each_with_index do |deal_product_budget, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * deal.days_per_month[index])
        monthly_budget = 0 if monthly_budget.between?(0, 1)
        total += monthly_budget.round(0)

        monthly_budget_loc = (daily_budget_loc * deal.days_per_month[index])
        monthly_budget_loc = 0 if monthly_budget_loc.between?(0, 1)
        total_loc += monthly_budget_loc.round(0)
      end
      deal_product_budget.update(budget: monthly_budget.round(0), budget_loc: monthly_budget_loc.round(0))
    end
  end

  def update_budget
    new_budget = deal_product_budgets.sum(:budget)
    new_budget_loc = deal_product_budgets.sum(:budget_loc)
    self.update(budget: new_budget, budget_loc: new_budget_loc)
  end

  def update_periods
    deal_product_budgets.each_with_index do |deal_product_budget, index|
      period = Date.new(*deal.months[index])
      deal_product_budget.start_date = [period, deal.start_date].max
      deal_product_budget.end_date = [period.end_of_month, deal.end_date].min
    end
  end

  def self.import(file, current_user)
    errors = []
    row_number = 0

    CSV.parse(file, headers: true) do |row|
      row_number += 1

      if row[0]
        begin
          deal = current_user.company.deals.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          error = { row: row_number, message: ["Deal ID #{row[0]} could not be found"] }
          errors << error
          next
        end
      end

      if row[1]
        if !(deal)
          deals = current_user.company.deals.where('name ilike ?', row[1].strip)
          if deals.length > 1
            error = { row: row_number, message: ["Deal Name #{row[1]} matched more than one deal record"] }
            errors << error
            next
          elsif deals.length < 1
            error = { row: row_number, message: ["Deal Name #{row[1]} did not match any Deal record"] }
            errors << error
            next
          end
          deal = deals.first
        end
      else
        error = { row: row_number, message: ["Deal Name can't be blank"] }
        errors << error
        next
      end

      if row[2]
        product = current_user.company.products.where('name ilike ?', row[2]).first
        unless product
          error = { row: row_number, message: ["Product #{row[2]} could not be found"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Product can't be blank"] }
        errors << error
        next
      end

      budget = nil
      if row[3]
        budget = Float(row[3].strip) rescue false
        budget_loc = budget
        unless budget
          error = { row: row_number, message: ["Budget must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Budget can't be blank"] }
        errors << error
        next
      end

      if deal.exchange_rate
        budget = budget_loc / deal.exchange_rate
      else
        error = { row: row_number, message: ["No active exchange rate for #{deal.curr_cd} at #{Date.today.strftime("%m/%d/%Y")}"] }
        errors << error
        next
      end

      deal_product_params = {
        deal_id: deal.id,
        budget: budget,
        budget_loc: budget_loc,
        product_id: product.id
      }

      deal_product = deal.deal_products.find_by(product: product)

      if !(deal_product)
        deal_product = deal.deal_products.new
      end

      if deal_product.update_attributes(deal_product_params)
        deal_product.deal.update_total_budget
      else
        error = { row: row_number, message: deal_product.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end
end
