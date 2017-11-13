class Api::V2::DisplayLineItemBudgetsController < ApiController
  respond_to :json

  def create
    if line_item_budget.valid?
      line_item_budget.perform
      log_transaction(imported: true)
      render json: line_item_budget, status: :created
    else
      log_transaction(imported: false)
      render json: { errors: line_item_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def log_transaction(imported:)
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'display_line_item_budget', source: 'api', rows_processed: 1)
    import_log.count_processed
    if imported
      import_log.count_imported
    else
      import_log.count_failed
      import_log.log_error line_item_budget.errors.full_messages
    end
    import_log.save
  end

  def line_item_budget
    @_line_item_budget ||= build_line_item_budget(line_item_budget_params)
  end

  def build_line_item_budget(params)
    DisplayLineItemBudgetCsvOperative.new(
      line_number: params[:line_number],
      budget_loc: params[:budget].to_f,
      month_and_year: params[:month_and_year],
      impressions: params[:impressions],
      revenue_calculation_pattern: 0,
      company_id: company_id
    )
  end

  def company_id
    @_company_id ||= current_user.company_id
  end

  def line_item_budget_params
    params.require(:display_line_item_budget).permit(
      :line_number,
      :budget,
      :month_and_year,
      :impressions,
      :revenue_calculation_pattern
    )
  end
end
