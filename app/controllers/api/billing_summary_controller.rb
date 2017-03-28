class Api::BillingSummaryController < ApplicationController
  respond_to :json

  def index
    render json: {
      ios_for_approval: ios_for_approval_serializer,
      ios_missing_display_line_items: ios_for_missing_display_line_items_serializer,
      ios_missing_monthly_actual: ios_missing_monthly_actual_serializer
    }
  end

  def update_quantity
    if display_line_item_budget.update(display_line_item_budget_params)
      display_line_item_budget.update({ budget: calculate_budget })
      display_line_item.update(manual_override: true)

      render json: { budget: display_line_item_budget.budget, quantity: display_line_item_budget.quantity}
    else
      render json: { errors: display_line_item_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_display_line_item_budget_billing_status
    if display_line_item_budget.update(display_line_item_budget_params)
      render json: { billing_status: display_line_item_budget.billing_status }
    else
      render json: { errors: display_line_item_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_content_fee_product_budget
    if content_fee_product_budget.update(content_fee_product_budget_params)
      render json: { billing_status: content_fee_product_budget.billing_status, budget: content_fee_product_budget.budget }
    else
      render json: { errors: content_fee_product_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def ios_for_approval_serializer
    ActiveModel::ArraySerializer.new(
      ios_for_time_period,
      each_serializer: BillingSummary::IosForApprovalSerializer,
      start_date: start_date,
      end_date: end_date
    )
  end

  def ios_for_missing_display_line_items_serializer
    ActiveModel::ArraySerializer.new(
      ios_for_missing_display_line_items,
      each_serializer: BillingSummary::IosForMissingDisplayLineItemsSerializer
    )
  end

  def ios_for_missing_display_line_items
    ios_for_time_period
      .with_won_deals
      .with_open_deal_products
      .with_display_revenue_type
      .without_display_line_items
      .includes(content_fees: [:content_fee_product_budgets], display_line_items: [:display_line_item_budgets],
                agency: [:address], advertiser: [:address], deal: { deal_contacts: :contact })
  end

  def ios_missing_monthly_actual_serializer
    ActiveModel::ArraySerializer.new(
      ios_missing_monthly_actual,
      each_serializer: BillingSummary::IosMissingMonthlyActualSerializer
    )
  end

  def ios_missing_monthly_actual
    DisplayLineItem.where(io: ios_for_time_period)
                   .joins(:display_line_item_budgets).without_budgets_by_date(start_date, end_date).uniq
  end

  def ios_for_time_period
    @_ios_for_time_period ||=
      company.ios.for_time_period(start_date, end_date)
  end

  def date
    @_date ||= [params[:year],params[:month]].join(' ').to_date
  end

  def start_date
    @_start_date ||= date.beginning_of_month
  end

  def end_date
    @_end_date ||= date.end_of_month
  end

  def company
    @_company ||= current_user.company
  end

  def display_line_item
    @_display_line_item ||= display_line_item_budget.display_line_item
  end

  def display_line_item_budget
    @_display_line_item_budget ||= DisplayLineItemBudget.find(params[:id])
  end

  def content_fee_product_budget
    ContentFeeProductBudget.find(params[:id])
  end

  def display_line_item_budget_params
    params.require(:display_line_item_budget).permit(:billing_status, :quantity)
  end

  def content_fee_product_budget_params
    params.require(:content_fee_product_budget).permit(:billing_status, :budget)
  end

  def calculate_budget
    (display_line_item_budget.quantity / 1000) * display_line_item.price.to_f
  end
end
