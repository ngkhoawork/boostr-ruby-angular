class Csv::IoCostDecorator
  def initialize(cost_monthly_amount, company, field)
    @cost_monthly_amount = cost_monthly_amount
    @company = company
    @field = field
  end

  def io_number
    io.io_number
  end

  def cost_id
    cost.id
  end

  def product_id
    product.id
  end

  def product_name
    product.name
  end

  def type
    value&.option&.name
  end

  def month
    cost_monthly_amount.start_date.strftime('%m/%Y')
  end

  def amount
    cost_monthly_amount.budget_loc
  end

  def io_name
    io.name
  end

  def io_seller
    highest_member&.name
  end

  def io_account_manager
    account_managers&.first&.name
  end

  def second_io_account_manager
    account_managers&.second&.name
  end

  private

  attr_reader :cost_monthly_amount, :company, :field

  def cost
    @_cost ||= cost_monthly_amount.cost
  end

  def io
    @_io ||= cost.io
  end

  def product
    @_product ||= cost.product
  end

  def account_managers
    @_account_managers ||= io.users.to_a.find_all {|u| u.user_type == ACCOUNT_MANAGER}
  end

  def highest_member
    io_member = io.io_members.sort_by{|m| m.share}.last
    io.users.find {|u| u.id == io_member&.user_id}
  end

  def value
    cost.values.to_a.find{|v| v.field_id == field.id}
  end
end
