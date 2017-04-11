class DisplayLineItemBudgetMonthsService
  def initialize(display_line_item, display_line_item_budget_serializer)
    @display_line_item = display_line_item
    @display_line_item_budget_serializer = display_line_item_budget_serializer.as_json
  end

  def perform
    new_display_line_item_budget_serializer
  end

  private

  attr_reader :display_line_item, :display_line_item_budget_serializer

  def readable_months
    TimePeriods.new(display_line_item.start_date..display_line_item.end_date).months_with_names(long_names: false)
  end

  def display_line_item_months
    readable_months.map { |obj| obj[:name] }
  end

  def existed_months
    display_line_item_budget_serializer.map { |obj| obj[:month] }
  end

  def months_without_display_line_item_budgets
    display_line_item_months - existed_months
  end

  def modified_display_line_item_budget_serializer
    months_without_display_line_item_budgets
      .each_with_object(display_line_item_budget_serializer) do |month, new_display_line_item_budget_serializer|
        new_display_line_item_budget_serializer << { month: month }
    end
  end

  def new_display_line_item_budget_serializer
    modified_display_line_item_budget_serializer.sort_by { |obj| obj[:month].to_date }
  end
end
