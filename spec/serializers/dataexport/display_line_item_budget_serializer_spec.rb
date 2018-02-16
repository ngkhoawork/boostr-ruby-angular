require 'rails_helper'

describe Dataexport::DisplayLineItemBudgetSerializer do
  it 'serializes display_line_item_budget data' do
    expect(serializer.id).to eq(display_line_item_budget.id)
    expect(serializer.display_line_item_id).to eq(display_line_item_budget.display_line_item_id)
    expect(serializer.budget_usd).to eq(display_line_item_budget.budget)
    expect(serializer.budget).to eq(display_line_item_budget.budget_loc)
    expect(serializer.start_date).to eq(display_line_item_budget.start_date)
    expect(serializer.end_date).to eq(display_line_item_budget.end_date)
    expect(serializer.created).to eq(display_line_item_budget.created_at)
    expect(serializer.last_updated).to eq(display_line_item_budget.updated_at)
    expect(serializer.manual_override).to eq(display_line_item_budget.manual_override)
    expect(serializer.ad_server_budget).to eq(display_line_item_budget.ad_server_budget)
    expect(serializer.ad_server_quantity).to eq(display_line_item_budget.ad_server_quantity)
    expect(serializer.quantity).to eq(display_line_item_budget.quantity)
  end

  private

  def serializer
    @_serializer ||= described_class.new(display_line_item_budget)
  end

  def display_line_item_budget
    @display_line_item_budget ||= create :display_line_item_budget,
                                         display_line_item: display_line_item,
                                         ad_server_budget: 100
  end

  def display_line_item
    @_display_line_item ||= create :display_line_item
  end
end
