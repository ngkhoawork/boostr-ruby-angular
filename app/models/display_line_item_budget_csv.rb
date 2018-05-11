class DisplayLineItemBudgetCsv
  include ActiveModel::Validations

  validates :company_id, :line_number, :month_and_year, :budget_loc, presence: true
  validates_presence_of :impressions, if: :should_validate_impressions

  attr_accessor :company_id, :external_io_number, :line_number, :month_and_year, :ctr, :impressions, :clicks,
                :video_avg_view_rate, :video_completion_rate, :budget_loc, :io_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    raise NotImplementedError.new("You must implement perform in child class")
  end

  private

  def create_or_update_display_line_item_budget
    display_line_item_budget.present? ? update_display_line_item_budget : new_display_line_item_budget
  end

  def new_display_line_item_budget
    display_line_item_budget.save
  end

  def update_display_line_item_budget
    display_line_item_budget.update!(display_line_item_budget_attributes) unless display_line_item_budget.manual_override?
  end

  def display_line_item
    @_display_line_item ||= io_or_tempio.display_line_items.find_by(line_number: line_number)
  end

  def display_line_item_budget_attributes
    {
      external_io_number: get_external_io_number,
      start_date: start_date,
      end_date: end_date,
      clicks: clicks,
      ctr: ctr,
      quantity: impressions,
      ad_server_quantity: impressions,
      budget: calculate_budget,
      budget_loc: calculate_budget_loc,
      ad_server_budget: calculate_budget_loc,
      video_avg_view_rate: video_avg_view_rate,
      video_completion_rate: video_completion_rate,
      invoice_id: invoice_id
    }
  end

  def display_line_item_budget
    @_display_line_item_budget ||= display_line_item.display_line_item_budgets.find_by(start_date: start_date)
    @_display_line_item_budget ||= display_line_item.display_line_item_budgets.new(display_line_item_budget_attributes)
  end

  def io_or_tempio
    io || tempio
  end

  def io
    @_io ||= Io.find_by(company_id: company_id, external_io_number: external_io_number)
    @_io ||= Io.find_by(company_id: company_id, io_number: io_number)
  end

  def tempio
    @_temp_io ||= TempIo.find_by(company_id: company_id, external_io_number: external_io_number)
  end

  def io_number
    io_name.gsub(/.+_/, '')
  end

  def should_validate_impressions
    true
  end
end
