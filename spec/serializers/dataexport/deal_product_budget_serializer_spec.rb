require 'rails_helper'

describe Dataexport::DealProductBudgetSerializer do
  let!(:company) { create :company }

  it 'serializes deal_product_budget data' do
    expect(serializer.deal_product_id).to eq(deal_product_budget.deal_product_id)
    expect(serializer.start_date).to eq(deal_product_budget.start_date)
    expect(serializer.end_date).to eq(deal_product_budget.end_date)
    expect(serializer.budget_usd).to eq(deal_product_budget.budget)
    expect(serializer.budget).to eq(deal_product_budget.budget_loc)
    expect(serializer.created).to eq(deal_product_budget.created_at)
    expect(serializer.last_updated).to eq(deal_product_budget.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(deal_product_budget)
  end

  def deal_product_budget
    @_deal_product_budget ||= create :deal_product_budget, deal_product: deal_product
  end

  def deal_product
    @_deal_product ||= create :deal_product
  end
end
