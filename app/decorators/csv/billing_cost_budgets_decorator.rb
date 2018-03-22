class Csv::BillingCostBudgetsDecorator
  def initialize(cost_budget, company, field)
    @cost_budget = cost_budget
    @company = company
    @field = field
  end

  def io_number
    io.io_number
  end

  def name
    io.name
  end

  def product
    cost.product.name
  end

  def amount
    cost_budget.budget_loc
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
