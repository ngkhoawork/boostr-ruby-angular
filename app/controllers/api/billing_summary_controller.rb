class Api::BillingSummaryController < ApplicationController
  respond_to :json

  def index
    render json: {
      ios_for_approval: ios_for_approval_serializer,
      ios_missing_display_line_items: ios_for_missing_display_line_items_serializer,
      ios_missing_monthly_actual: ios_missing_monthly_actual_serializer
    }
  end

  def costs
    render json: billing_costs_serializer
  end

  def update_quantity
    if display_line_item_budget.update(display_line_item_budget_params)
      update_display_line_item_budget

      render json: { quantity: display_line_item_budget.quantity, budget_loc: display_line_item_budget.budget_loc.to_f }
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
      update_manual_override
      update_io_budget

      render json: { billing_status: content_fee_product_budget.billing_status,
                     budget_loc: content_fee_product_budget.budget_loc }
    else
      render json: { errors: content_fee_product_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_cost
    if cost.update(cost_params)
      render json: cost.reload, serializer: BillingSummary::CostSerializer
    else
      render json: { errors: cost.errors.messages }, status: :unprocessable_entity
    end
  end

  def export
    respond_to do |format|
      format.csv { send_data billing_summary_csv_report,
                   filename: "billing-summary-revenue#{params[:month]}-#{params[:year]}.csv" }
    end
  end

  def export_costs
    respond_to do |format|
      format.csv { send_data billing_summary_costs_csv_report,
                   filename: "billing-summary-costs-#{Date.today}.csv" }
    end
  end

  private

  def billing_summary_costs_csv_report
    Csv::BillingCostsService.new(company, billing_costs_data).perform
  end

  def billing_costs_serializer
    ActiveModel::ArraySerializer.new(
      billing_costs_data,
      each_serializer: BillingSummary::CostSerializer
    )
  end

  def billing_costs_data
    BillingCostsQuery.new(billing_costs_params).perform
  end

  def billing_costs_params
    params
      .permit(:team_id, :user_id, :user_type)
      .merge(company_id: current_user.company_id)
  end

  def ios_for_approval_serializer
    ActiveModel::ArraySerializer.new(
      company.ios,
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

  def display_line_items_without_budgets_by_date
    DisplayLineItem.by_period_without_budgets(start_date, end_date, ios_for_time_period.ids)
  end

  def display_line_items_with_budgets_by_date
    DisplayLineItem.by_period_with_budgets(start_date, end_date, ios_for_time_period.ids)
  end

  def ios_missing_monthly_actual
    (display_line_items_without_budgets_by_date - display_line_items_with_budgets_by_date) +
    DisplayLineItem.by_period_without_display_line_item_budgets(start_date, end_date, ios_for_time_period.ids)
  end

  def ios_for_time_period
    @_ios_for_time_period ||=
      company.ios.for_time_period(start_date, end_date)
  end

  def date
    @_date ||= [params[:year], params[:month]].join(' ').to_date
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

  def cost
    @_cost ||= Cost.find(params[:id])
  end

  def display_line_item
    @_display_line_item ||= display_line_item_budget.display_line_item
  end

  def display_line_item_budget
    @_display_line_item_budget ||= DisplayLineItemBudget.find(params[:id])
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= ContentFeeProductBudget.find(params[:id])
  end

  def content_fee
    @_content_fee ||= content_fee_product_budget.content_fee
  end

  def cost_params
    params.require(:cost).permit(
      :budget_loc,
      :product_id,
      :type,
      {
        values_attributes: [
          :id,
          :field_id,
          :option_id,
          :value
        ],
      }
    )
  end

  def display_line_item_budget_params
    params.require(:display_line_item_budget).permit(:billing_status, :quantity)
  end

  def content_fee_product_budget_params
    params.require(:content_fee_product_budget).permit(:billing_status, :budget_loc)
  end

  def calculate_budget
    @_budget ||= (display_line_item_budget.quantity / 1000) * display_line_item.price.to_f
  end

  def update_manual_override
    content_fee_product_budget.update(manual_override: true) if content_fee_product_budget_params[:budget_loc].present?
  end

  def update_display_line_item_budget
    display_line_item_budget.update(
      {
        budget_loc: calculate_budget,
        budget: (calculate_budget / display_line_item.io.exchange_rate),
        manual_override: true
      }
    )
  end

  def update_io_budget
    content_fee_product_budget.update(
      { budget: (content_fee_product_budget.budget_loc / content_fee.io.exchange_rate).to_i }
    )

    content_fee.update_column(:budget, content_fee.content_fee_product_budgets.pluck(:budget).sum)
    content_fee.update_column(:budget_loc, content_fee.content_fee_product_budgets.pluck(:budget_loc).sum)

    content_fee.io.update(
      { budget: (content_fee.io.content_fees.pluck(:budget).sum +
                 content_fee.io.display_line_item_budgets.pluck(:budget).sum),
        budget_loc: (content_fee.io.content_fees.pluck(:budget_loc).sum +
                     content_fee.io.display_line_item_budgets.pluck(:budget_loc).sum)
      }
    )
  end

  def csv_data
    @_csv_data ||= JSON.parse ios_for_approval_serializer.to_json
  end

  def billing_summary_csv_report
    headers = [
      'Io#', 'Line#', 'Name', 'Advertiser', 'Agency', 'Seller', 'Currency', 'Billing Contact Name', 'Billing Contact Email',
      'Billing Contact Address1', 'Billing Contact City', 'Billing Contact State', 'Billing Contact Country',
      'Billing Contact Postal Code', 'Product', 'Ad Server Product', 'Revenue Type', 'Amount', 'Billing Status', 'VAT'
    ]

    CSV.generate do |csv|
      csv << headers

      csv_data.each do |obj|
        obj['content_fee_product_budgets'].each do |fee|
          csv << fee.values_at('io_number', 'line', 'io_name', 'advertiser_name', 'agency_name', 'seller_name', 'currency',
                               'billing_contact_name', 'billing_contact_email', 'street1', 'city', 'state', 'country',
                               'postal_code', 'product_name', 'ad_server', 'revenue_type', 'amount', 'billing_status',
                               'vat')
        end

        obj['display_line_item_budgets'].each do |item|
          csv << item.values_at('io_number', 'line', 'io_name', 'advertiser_name', 'agency_name', 'seller_name', 'currency',
                                'billing_contact_name', 'billing_contact_email', 'street1', 'city', 'state', 'country',
                                'postal_code', 'product_name', 'ad_server', 'revenue_type', 'budget_loc',
                                'billing_status', 'vat')
        end
      end
    end
  end
end
