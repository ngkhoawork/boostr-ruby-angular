class Csv::BillingCostBudgetsDecorator
  def initialize(cost_budget, field, company)
    @cost_budget = cost_budget
    @field = field
    @company = company
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
    io.sellers&.map(&:name).join(',')
  end

  def account_manager
    io.account_managers&.map(&:name).join(',')
  end

  def actualization_status
    cost_budget.actual_status
  end

  def product
    cost.product&.level0&.[]('name')
  end

  def amount
    cost_budget.budget_loc.to_f
  end

  def cost_type
    value&.option&.name
  end

  def method_missing(name)
    if company.product_options_enabled && company.product_option1_enabled && name.eql?(product_option1)
      cost.product&.level1&.[]('name')
    elsif company.product_options_enabled && company.product_option2_enabled && name.eql?(product_option2)
      cost.product&.level2&.[]('name')
    end
  end

  private

  attr_reader :cost_budget, :field, :company

  def parameterize(name)
    Csv::BaseService.parameterize(name).to_sym
  end

  def product_option1
    parameterize(company.product_option1)
  end

  def product_option2
    parameterize(company.product_option2)
  end

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
