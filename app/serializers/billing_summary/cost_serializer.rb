class BillingSummary::CostSerializer < ActiveModel::Serializer
  attributes :id, :product, :amount, :io_id, :io_number,
              :io_name, :values, :currency, :currency_symbol

  def amount
    object.budget_loc.to_f
  end

  def product
    object.product.name
  end

  def io_number
    io.io_number
  end

  def io_name
    io.name
  end

  def currency
    io.curr_cd
  end

  def currency_symbol
    io.currency.curr_symbol
  end

  def io
    object.io
  end
end
