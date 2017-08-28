class DisplayLineItemBudgetCsv
  include ActiveModel::Validations

  validates :company_id, :external_io_number, :line_number, :month_and_year, :ctr, :impressions, :clicks,
            :video_avg_view_rate, :video_completion_rate, :budget_loc, presence: true

  attr_accessor :company_id, :external_io_number, :line_number, :month_and_year, :ctr, :impressions, :clicks,
                :video_avg_view_rate, :video_completion_rate, :budget_loc, :io_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?
    update_external_io_number
    if io_or_tempio && display_line_item
      create_or_update_display_line_item_budget
    end
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
      external_io_number: external_io_number,
      start_date: start_date,
      end_date: end_date,
      clicks: clicks,
      ctr: ctr,
      quantity: impressions,
      ad_server_quantity: impressions,
      budget: budget,
      budget_loc: calculate_budget_loc,
      ad_server_budget: calculate_budget_loc,
      video_avg_view_rate: video_avg_view_rate,
      video_completion_rate: video_completion_rate,
      has_dfp_budget_correction: true
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
    @_io ||= company.ios.find_by(external_io_number: external_io_number)
    @_io ||= company.ios.find_by(io_number: io_number)
  end

  def tempio
    @_temp_io ||= company.temp_ios.find_by(external_io_number: external_io_number)
  end

  def io_number
    io_name.gsub(/.+_/, '')
  end

  def update_external_io_number
    if io && external_io_number
      io.update_columns(external_io_number: external_io_number)
    end
  end

  def company
    Company.find(company_id)
  end

  def start_date
    @_start_date ||= Date.strptime(month_and_year, '%Y-%m')
  end

  def dfp_end_date
    @_dfp_end_date ||= start_date.end_of_month
  end

  def end_date
    dfp_end_date > display_line_item.end_date ? display_line_item.end_date : dfp_end_date
  end

  def budget
    display_line_item.price * impressions / 1_000
  end

  def calculate_budget_loc
    display_line_item.price * budget_loc / 1_000
  end

  def sum_of_monthly_budgets
    (display_line_item.display_line_item_budgets.where.not(id: display_line_item_budget.id).sum(:budget_loc) + display_line_item_budget.budget_loc)
  end

end
