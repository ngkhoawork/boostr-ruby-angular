require 'rails_helper'

describe DisplayLineItemBudgetMonthsService do
  it 'has proper display line item budgets data' do
    display_line_item_budget = create :display_line_item_budget,
                                      display_line_item: display_line_item,
                                      budget: 10_000,
                                      budget_loc: 10_000,
                                      start_date: '01/11/2016',
                                      end_date: '30/11/2016'

    result = display_line_item_budget_months_service.perform

    expect(result.first[:month]).to eq 'Oct 2016'
    expect(result.last[:month]).to eq 'Nov 2016'
    expect(result.last[:id]).to eq display_line_item_budget.id
    expect(result.last[:budget_loc]).to eq display_line_item_budget.budget_loc
  end

  private

  def display_line_item_budget_months_service
    described_class.new(display_line_item, display_line_item_budget_serializer)
  end

  def display_line_item_budget_serializer
    ActiveModel::ArraySerializer.new(
      display_line_item.display_line_item_budgets,
      each_serializer: DisplayLineItemBudgetSerializer
    )
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      price: 10,
      budget: 20_000,
      budget_loc: 20_000,
      start_date: '01/10/2016',
      end_date: '30/11/2016'
    )
  end
end
