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
    product&.level0&.name
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

  def method_missing(name)
    if company.product_options_enabled && name.eql?(product_option1)
      product&.level1&.name
    elsif company.product_options_enabled && name.eql?(product_option2)
      product&.level2&.name
    end
  end

  private

  attr_reader :cost_monthly_amount, :company, :field

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
