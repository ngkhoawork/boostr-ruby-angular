class BillingSummary::CostBudgetSerializer < ActiveModel::Serializer
  attributes :id, :product, :amount, :cost_id, :io_id, :io_number,
              :io_name, :values, :currency, :currency_symbol

  def amount
    object.budget_loc.to_f
  end

  def product
    cost.product.name
  end

  def io_number
    io.io_number
  end

  def io_name
    io.name
  end

  def io_id
    cost.io_id
  end

  def values
    cost.values
  end

  def currency
    io.curr_cd
  end

  def currency_symbol
    io.currency.curr_symbol
  end

  def cost
    object.cost
  end

  def io
    cost.io
  end
end
