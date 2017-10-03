class Facts::AdvertiserAgencyRevenueCalculationService < BaseService

  attr_reader :calculated_revenues

  def self.perform(params)
    self.new(start_date: params[:start_date], end_date: params[:end_date], company_id: params[:company_id]).tap do |instance|
      instance.calculate_revenues
    end
  end

  def calculate_revenues
    @calculated_revenues = [content_fee_products_budgets, display_products_budgets, display_line_items_daily_rate_budgets].inject(:union)
  end

  private

  def content_fee_products_budgets
    content_fees_with_monthly_budgets.group('ios.advertiser_id, ios.agency_id, ios.company_id')
        .select('ios.advertiser_id as advertiser_id,
                 ios.agency_id as agency_id,
                 ios.company_id,
                 SUM(ceil(content_fee_product_budgets.budget::DOUBLE PRECISION)) as revenue_amount')
  end

  def display_products_budgets
    lines_with_monthly_budgets.group('ios.advertiser_id, ios.agency_id, ios.company_id')
        .select('ios.advertiser_id as advertiser_id,
                ios.agency_id as agency_id,
                ios.company_id,
                SUM(ceil(display_line_item_budgets.budget::DOUBLE PRECISION)) as revenue_amount')
  end

  def display_line_items_daily_rate_budgets
    lines_without_monthly_budgets.group('ios.advertiser_id, ios.agency_id, ios.company_id')
        .select('ios.advertiser_id as advertiser_id,
                 ios.agency_id as agency_id,
                 ios.company_id,
                 SUM(ceil(display_line_items.daily_run_rate::DOUBLE PRECISION)) as revenue_amount')
  end

  def lines_with_monthly_budgets
    DisplayLineItemBudget.joins(display_line_item: :product)
        .joins('INNER JOIN ios on ios.id = display_line_items.io_id')
        .where(display_products_budgets_conditions,
               company_id: company_id,
               start_date: start_date,
               end_date: end_date)
  end

  def content_fees_with_monthly_budgets
    ContentFeeProductBudget.joins(content_fee: :io)
        .where(content_fee_budgets_conditions,
               company_id: company_id,
               start_date: start_date,
               end_date: end_date)
  end

  def lines_without_monthly_budgets
    DisplayLineItem.joins(product: :company)
        .joins('INNER JOIN ios on ios.id = display_line_items.io_id')
        .where(display_line_item_budgets_daily_rate_conditions,
               company_id: company_id,
               display_line_item_ids: lines_with_monthly_budgets.pluck(:display_line_item_id),
               start_date: start_date,
               end_date: end_date)
  end

  def content_fee_budgets_conditions
    'ios.company_id = :company_id
     AND content_fee_product_budgets.end_date >= :start_date
     AND content_fee_product_budgets.start_date <= :end_date'
  end

  def display_line_item_budgets_daily_rate_conditions
    'display_line_items.end_date >= :start_date
     AND display_line_items.start_date <= :end_date
     AND display_line_items.id NOT IN (:display_line_item_ids)
     AND products.revenue_type = \'Display\'
     AND ios.company_id = :company_id'
  end

  def display_products_budgets_conditions
    'display_line_item_budgets.end_date >= :start_date
     AND display_line_item_budgets.start_date <= :end_date
     AND products.revenue_type = \'Display\'
     AND ios.company_id = :company_id'
  end
end