class Api::BillingSummaryController < ApplicationController
  respond_to :json

  def index
    render json: {
      ios_for_approval: ios_for_approval_serializer,
      ios_missing_display_line_items: ios_for_missing_display_line_items_serializer,
      ios_missing_monthly_actual: ios_missing_monthly_actual_serializer
    }
  end

  private

  def ios_for_missing_display_line_items
    ios_for_time_period
      .with_won_deals
      .with_open_deal_products
      .with_display_revenue_type
      .without_display_line_items
  end

  def ios_for_missing_display_line_items_serializer
    ActiveModel::ArraySerializer.new(
      ios_for_missing_display_line_items,
      each_serializer: BillingSummary::IosForMissingDisplayLineItemsSerializer
    )
  end

  def ios_for_approval_serializer
    ActiveModel::ArraySerializer.new(
      ios_for_time_period,
      each_serializer: BillingSummary::IosForApprovalSerializer,
      start_date: start_date,
      end_date: end_date
    )
  end

  def ios_missing_monthly_actual_serializer
    ActiveModel::ArraySerializer.new(
      ios_missing_monthly_actual,
      each_serializer: BillingSummary::IosMissingMonthlyActualSerializer
    )
  end

  def ios_missing_monthly_actual
    DisplayLineItem.where(io: ios_for_time_period)
                   .joins(:display_line_item_budgets).without_budgets_by_date(start_date, end_date)
  end

  def ios_for_time_period
    @_ios_for_time_period ||=
      company.ios.for_time_period(start_date, end_date)
      .includes(content_fees: [:content_fee_product_budgets], display_line_items: [:display_line_item_budgets],
                agency: [:address], advertiser: [:address], deal: { deal_contacts: :contact })
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
end
