class Csv::IoCostDecorator
  def initialize(cost_monthly_amount, company)
    @cost_monthly_amount = cost_monthly_amount
    @company = company
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
    cost.values.find_by(field: field).option.name rescue nil
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
    io.highest_member&.name
  end

  def io_account_manager
    io.account_manager.first&.name
  end

  def second_io_account_manager
    io.account_manager.second&.name
  end

  private

  attr_reader :cost_monthly_amount, :company

  def cost
    @_cost ||= cost_monthly_amount.cost
  end

  def io
    @_io ||= cost.io
  end

  def product
    @_product ||= cost.product
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
