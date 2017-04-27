class Api::DisplayLineItemBudgetsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            # Something that should be interrupted if it takes too much time...
            send_data DisplayLineItemBudget.to_csv(current_user.company_id), filename: "display-line-item-budgets-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DisplayLineItemBudget.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end

  def update
    if display_line_item_budget.update(display_line_item_budget_params)
      update_budget

      render json: { budget_loc: display_line_item_budget.budget_loc }
    else
      render json: { errors: display_line_item_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def display_line_item_budget
    @_display_line_item_budget ||= DisplayLineItemBudget.find(params[:id])
  end

  def display_line_item_budget_params
    params.require(:display_line_item_budget).permit(:budget_loc)
  end

  def update_budget
    return unless display_line_item_budget.budget_loc.present?

    display_line_item_budget.update(
      budget: (display_line_item_budget.budget_loc / display_line_item_budget.display_line_item.io.exchange_rate),
      manual_override: true
    )
  end
end
