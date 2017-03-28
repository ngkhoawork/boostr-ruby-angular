class BillingSummary::IosForApprovalSerializer < ActiveModel::Serializer
  has_many :content_fee_product_budgets, serializer: BillingSummary::ContentFeeProductBudgetsSerializer
  has_many :display_line_item_budgets, serializer: BillingSummary::DisplayLineItemBudgetsSerializer

  def content_fee_product_budgets
    object.content_fee_product_budgets.for_time_period(start_date, end_date).includes(content_fee: [:io, :product])
  end

  def display_line_item_budgets
    object.display_line_item_budgets.by_date(start_date, end_date)
  end

  def start_date
    options[:start_date]
  end

  def end_date
    options[:end_date]
  end
end
