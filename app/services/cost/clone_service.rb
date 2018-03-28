class Cost::CloneService
  attr_reader :cost_monthly_amounts, :cost, :io, :new_cost
  
  def initialize(cost)
    @cost = cost
    @cost_monthly_amounts = cost.cost_monthly_amounts
    @io = cost.io
  end

  def perform
    @new_cost = clone_cost
    clone_budgets
    clone_type
    calculate_forecast

    @new_cost
  end

  private

  def clone_cost
    new_cost = cost.dup
    new_cost.skip_callback = true
    new_cost.save
    new_cost
  end

  def clone_budgets
    cost.cost_monthly_amounts.each do |cost_monthly_amount|
      new_cost_monthly_amount = cost_monthly_amount.dup
      new_cost_monthly_amount.cost_id = new_cost.id
      new_cost_monthly_amount.save
    end
  end

  def clone_type
    new_value = cost_type_value.dup
    new_value.subject_id = new_cost.id
    new_value.save
  end

  def calculate_forecast
    new_cost.update_revenue_budget
  end

  def company
    @_company ||= io.company
  end

  def cost_type_field
    @_cost_type_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end

  def cost_type_value
    @_cost_type_value ||= cost.values.to_a.find{|v| v.field_id == cost_type_field.id}
  end
end
