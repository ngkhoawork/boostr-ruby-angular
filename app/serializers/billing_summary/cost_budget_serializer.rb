class BillingSummary::CostBudgetSerializer < ActiveModel::Serializer
  attributes :id, :product, :amount, :cost_id, :io_id, :io_number, :actual_status,
              :io_name, :values, :currency, :currency_symbol, :agency, :advertiser,
              :sellers, :account_managers, :is_estimated

  def amount
    object.budget_loc.to_f
  end

  def agency
    io.agency&.name
  end

  def is_estimated
    cost.is_estimated
  end

  def sellers
    io.sellers
  end

  def account_managers
    io.account_managers
  end

  def advertiser
    io.advertiser&.name
  end

  def product
    cost.product
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
    io.currency&.curr_symbol
  end

  def cost
    object.cost
  end

  def io
    cost.io
  end
end
