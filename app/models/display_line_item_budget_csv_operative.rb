class DisplayLineItemBudgetCsvOperative < DisplayLineItemBudgetCsv
  include ActiveModel::Validations

  validates :company_id, :line_number, :month_and_year, :budget_loc, presence: true

  attr_accessor :company_id, :external_io_number, :line_number, :month_and_year,
                :ctr, :impressions, :clicks, :video_avg_view_rate, :video_completion_rate,
                :budget_loc, :io_name, :revenue_calculation_pattern, :invoice_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?
    if display_line_item && io_or_tempio
      create_or_update_display_line_item_budget
    end
  end

  def irrelevant?
    !display_line_item || !io_or_tempio
  end

  private

  def display_line_item
    @_display_line_item ||= DisplayLineItem.joins(:io).find_by(line_number: line_number, 'ios.company_id': company_id)
    @_display_line_item ||= DisplayLineItem.joins(:temp_io).find_by(line_number: line_number, 'temp_ios.company_id': company_id)
  end

  def display_line_item_budget
    @_display_line_item_budget ||= display_line_item.display_line_item_budgets.find_by(invoice_id: invoice_id)
    @_display_line_item_budget ||= display_line_item.display_line_item_budgets.find_by(start_date: start_date)
    @_display_line_item_budget ||= display_line_item.display_line_item_budgets.new(display_line_item_budget_attributes)
  end

  def io_or_tempio
    display_line_item.io || display_line_item.temp_io
  end

  def start_date
    @_start_date ||= Date.strptime(month_and_year, '%m-%Y') rescue nil
    @_start_date ||= Date.strptime(month_and_year, '%B-%Y')
  end

  def item_end_date
    @_item_end_date ||= start_date.end_of_month
  end

  def end_date
    item_end_date > display_line_item.end_date ? display_line_item.end_date : item_end_date
  end

  def calculate_budget
    io_or_tempio.convert_to_usd(calculate_budget_loc)
  end

  def calculate_budget_loc
    if revenue_calculation_pattern == 0
      @_calculated_budget_loc = budget_loc * display_line_item.price
    else
      @_calculated_budget_loc = budget_loc
    end
    @_calculated_budget_loc
  end

  def get_external_io_number
    io_or_tempio.external_io_number
  end

  def should_validate_impressions
    false
  end
end
