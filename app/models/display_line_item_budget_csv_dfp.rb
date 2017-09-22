class DisplayLineItemBudgetCsvDfp < DisplayLineItemBudgetCsv
  include ActiveModel::Validations

  validates :company_id, :line_number, :month_and_year, :impressions, :budget_loc, 
            :external_io_number, :ctr, :clicks, :video_avg_view_rate,
            :video_completion_rate, presence: true

  def perform
    return self.errors.full_messages unless self.valid?
    update_external_io_number
    if io_or_tempio && display_line_item
      create_or_update_display_line_item_budget
    end
  end

  private

  def display_line_item_budget_attributes
    super.merge({ has_dfp_budget_correction: true })
  end

  def update_external_io_number
    if io && external_io_number
      io.update_columns(external_io_number: external_io_number)
    end
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

  def calculate_budget
    display_line_item.price * impressions / 1_000
  end

  def calculate_budget_loc
    display_line_item.price * budget_loc / 1_000
  end

  def get_external_io_number
    external_io_number
  end
end
