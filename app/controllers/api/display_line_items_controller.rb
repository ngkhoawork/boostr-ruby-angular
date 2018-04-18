class Api::DisplayLineItemsController < ApplicationController
  respond_to :json

  def index
    render json: display_line_items.as_json( include: {
        io: {
            include: {
                advertiser: {},
                agency: {},
                currency: { only: :curr_symbol }
            }
        }
    })
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'DisplayLineItem',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    end
  end

  def show
    render json: display_line_item_budget_months_service.perform
  end

  def add_budget
    display_line_item_budget = display_line_item.display_line_item_budgets.new(budget_attributes)

    if display_line_item_budget.save
      render json: display_line_item_budget
    else
      render json: { errors: display_line_item_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def display_line_items
    dashboard_pacing_alert_service
      .filtered_line_items
      .limit(limit)
      .offset(offset)
  end

  def dashboard_pacing_alert_service
    DashboardPacingAlertService.new(current_user: current_user, params: params)
  end

  def company
    current_user.company
  end

  def display_line_item
    @_display_line_item ||= DisplayLineItem.find(params[:id])
  end

  def display_line_item_budget_serializer
    ActiveModel::ArraySerializer.new(
      display_line_item.display_line_item_budgets,
      each_serializer: DisplayLineItemBudgetSerializer
    )
  end

  def display_line_item_budget_months_service
    DisplayLineItemBudgetMonthsService.new(display_line_item, display_line_item_budget_serializer)
  end

  def display_line_item_budget_params
    params.require(:display_line_item_budget).permit(:budget_loc, :month)
  end

  def budget_attributes
    {
      budget: display_line_item.io.convert_to_usd(display_line_item_budget_params['budget_loc']),
      budget_loc: display_line_item_budget_params['budget_loc'],
      start_date: display_line_item_budget_params['month'].to_date.beginning_of_month,
      end_date: display_line_item_budget_params['month'].to_date.end_of_month,
      manual_override: true
    }
  end
end
