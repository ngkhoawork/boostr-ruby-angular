class Csv::BillingCostBudgetsDecorator
  def initialize(cost_budget, field)
    @cost_budget = cost_budget
    @field = field
  end

  def io_number
    io.io_number
  end

  def name
    io.name
  end

  def advertiser
    io.advertiser&.name
  end

  def agency
    io.agency&.name
  end

  def seller
    io.sellers&.map(&:name).join(';')
  end

  def account_manager
    io.account_managers&.map(&:name).join(';')
  end

  def actualization_status
    cost_budget.actual_status
  end

  def product
    cost.product&.name
  end

  def amount
    cost_budget.budget_loc.to_f
  end

  def cost_type
    value&.option&.name
  end

  private

  attr_reader :cost_budget, :field

  def cost
    cost_budget.cost
  end

  def io
    @_io ||= cost.io
  end

  def value
    cost.values.to_a.find{|v| v.field_id == field.id}
  end
end
