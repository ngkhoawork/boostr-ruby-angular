require 'rails_helper'

describe BillingSummary::CostBudgetSerializer do
  let!(:company) { create :company }

  it 'serializes cost budget data' do
    expect(serializer.id).to eq(cost_budget.id)
    expect(serializer.product).to eq(cost.product.name)
    expect(serializer.amount).to eq(cost_budget.budget_loc)
    expect(serializer.cost_id).to eq(cost_budget.cost_id)
    expect(serializer.io_id).to eq(io.id)
    expect(serializer.io_number).to eq(io.io_number)
    expect(serializer.actual_status).to eq(cost_budget.actual_status)
    expect(serializer.io_name).to eq(io.name)
    expect(serializer.currency).to eq(io.curr_cd)
    expect(serializer.currency_symbol).to eq(io.currency&.curr_symbol)
    expect(serializer.agency).to eq(io.agency&.name)
    expect(serializer.advertiser).to eq(io.advertiser&.name)
    expect(serializer.sellers).to eq(io.sellers)
    expect(serializer.account_managers).to eq(io.account_managers)
    expect(serializer.is_estimated).to eq(cost.is_estimated)
  end

  private

  def serializer
    @_serializer ||= described_class.new(cost_budget)
  end

  def io
    @_io ||= create :io, advertiser: advertiser, agency: agency, company: company
  end

  def company
    @_company ||= create :company
  end

  def advertiser
    @_advertiser ||= create :client
  end

  def product
    @_product ||= create :product
  end

  def agency
    @_agency ||= create :client
  end

  def cost
    @_cost ||= create :cost, io: io, product: product
  end

  def cost_budget
    cost_monthly_amounts.first
  end

  def cost_monthly_amounts
    @_cost_monthly_amounts ||= cost.cost_monthly_amounts
  end
end
