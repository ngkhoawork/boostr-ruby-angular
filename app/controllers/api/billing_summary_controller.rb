class Api::BillingSummaryController < ApplicationController
  respond_to :json

  def index
    render json: {
      ios_for_approval: ios_for_approval_serialializer,
      ios_missing_display_line_items: ios_for_missing_display_line_items_serialializer,
      ios_missing_monthly_actual: ''
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

  def ios_for_missing_display_line_items_serialializer
    ActiveModel::ArraySerializer.new(
      ios_for_missing_display_line_items,
      each_serializer: BillingSummary::IosForMissingDisplayLineItemsSerializer
    )
  end

  def ios_for_approval_serialializer
    ActiveModel::ArraySerializer.new(
      ios_for_time_period,
      each_serializer: BillingSummary::IosForTimePeriodSerializer
    )
  end

  def ios_for_time_period
    company.ios.for_time_period(date.beginning_of_month, date.end_of_month)
      .includes(:content_fee_product_budgets, :display_line_item_budgets, :agency,
                :advertiser, deal: { deal_contacts: :contact })
  end

  def date
    @_date ||= [params[:year], params[:month]].join(' ').to_date
  end

  def company
    @_company ||= current_user.company
  end
end
