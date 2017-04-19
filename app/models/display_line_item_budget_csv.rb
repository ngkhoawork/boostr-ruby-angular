class DisplayLineItemBudgetCsv
  include ActiveModel::Validations

  validates :company_id, :external_io_number, :line_number, :month_and_year, :ctr, :impressions, :clicks,
            :video_avg_view_rate, :video_completion_rate, presence: true

  attr_accessor :company_id, :external_io_number, :line_number, :month_and_year, :ctr, :impressions, :clicks,
                :video_avg_view_rate, :video_completion_rate

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?

    if io_or_tempio && display_line_item
      create_or_update_display_line_item_budget
    end
  end

  private

  def create_or_update_display_line_item_budget
    display_line_item_budget.present? ? update_display_line_item_budget : create_display_line_item_budget
  end

  def create_display_line_item_budget
    display_line_item.display_line_item_budgets.create(
      external_io_number: external_io_number,
      start_date: start_date,
      end_date: end_date,
      clicks: clicks,
      ctr: ctr,
      quantity: impressions,
      ad_server_quantity: impressions,
      budget: budget,
      budget_loc: budget,
      video_avg_view_rate: video_avg_view_rate,
      video_completion_rate: video_completion_rate
    )
  end

  def update_display_line_item_budget
    display_line_item_budget.update(
      ad_server_quantity: impressions
    )
  end

  def display_line_item
    @_display_line_item ||= io_or_tempio.display_line_items.find_by(line_number: line_number)
  end

  def display_line_item_budget
    display_line_item.display_line_item_budgets.find_by(start_date: start_date)
  end

  def io_or_tempio
    io || tempio
  end

  def io
    @_io ||= company.ios.find_by(external_io_number: external_io_number)
  end

  def tempio
    @_temp_io ||= company.temp_ios.find_by(external_io_number: external_io_number)
  end

  def company
    Company.find(company_id)
  end

  def start_date
    @_start_date ||= Date.strptime(month_and_year, '%Y-%m')
  end

  def end_date
    start_date.end_of_month
  end

  def budget
    display_line_item.price * impressions.to_i
  end
end
