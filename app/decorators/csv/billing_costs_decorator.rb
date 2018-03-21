class Csv::BillingCostsDecorator
  def initialize(cost, company, field)
    @cost = cost
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
    cost.budget_loc
  end

  def cost_type
    value&.option&.name
  end

  private

  attr_reader :cost, :field

  def io
    @_io ||= cost.io
  end

  def value
    cost.values.to_a.find{|v| v.field_id == field.id}
  end
end
