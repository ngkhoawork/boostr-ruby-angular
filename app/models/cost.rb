class Cost < ActiveRecord::Base
  belongs_to :company
  belongs_to :io
  belongs_to :product

  has_many :values, as: :subject

  has_many :cost_monthly_amounts, dependent: :destroy

  validate :active_exchange_rate

  accepts_nested_attributes_for :cost_monthly_amounts
  accepts_nested_attributes_for :values

  after_create do
    Cost::AmountsGenerateService.new(self).perform if self.cost_monthly_amounts.count == 0
  end

  after_update do
    if cost_monthly_amounts.sum(:budget) != budget || cost_monthly_amounts.sum(:budget_loc) != budget_loc
      if budget_changed? || budget_loc_changed?
        Cost::AmountsUpdateService.new(self).perform
      else
        self.update_budget
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
    self.update(budget: new_budget, budget_loc: new_budget_loc)
  end

  def daily_budget
    budget / (io.end_date - io.start_date + 1)
  end

  def daily_budget_loc
    budget_loc / (io.end_date - io.start_date + 1)
  end

  def active_exchange_rate
    if io.curr_cd != 'USD'
      unless io.exchange_rate
        errors.add(:curr_cd, "does not have an exchange rate for #{io.curr_cd} at #{io.created_at.strftime("%m/%d/%Y")}")
      end
    end
  end

  def update_periods
    cost_monthly_amounts.each_with_index do |cost_monthly_amount, index|
      period = Date.new(*io.months[index])
      cost_monthly_amount.start_date = [period, io.start_date].max
      cost_monthly_amount.end_date = [period.end_of_month, io.end_date].min
    end
  end
end
