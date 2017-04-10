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
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DisplayLineItem.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end

  def show
    # modified_hash
    # binding.pry
    render json: modified_hash
  end

  private

  def display_line_items
    dashboard_pacing_alert_service.filtered_line_items
  end

  def dashboard_pacing_alert_service
    DashboardPacingAlertService.new(current_user: current_user, params: params)
  end

  def company
    current_user.company
  end

  def display_line_item
    @_display_line_item ||= current_user.display_line_items.find(params[:id])
  end

  def display_line_item_budget_serializer
    ActiveModel::ArraySerializer.new(
      display_line_item.display_line_item_budgets,
      each_serializer: DisplayLineItemBudgetSerializer
    ).as_json
  end

  def io_months
    display_line_item.io.readable_months.map { |obj| obj[:name] }
  end

  def existed_months
    display_line_item_budget_serializer.map { |obj| obj[:month] }
  end

  def months_without_display_line_item_budgets
    io_months - existed_months
  end

  def modified_hash
    months_without_display_line_item_budgets.each_with_object(display_line_item_budget_serializer) do |month, sum|
      sum << { month: month }
    end.sort_by { |obj| month_data[:obj].to_date  }
  end
end
