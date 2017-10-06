class Facts::AccountProductRevenueCalculationService < BaseService

  attr_reader :calculated_revenues

  def self.perform(params)
    self.new(params).tap do |instance|
      instance.calculate_revenues
    end
  end

  def calculate_revenues
    @calculated_revenues = ContentFeeProductBudget
                               .select('revenues.account_dimension_id, revenues.company_id, revenues.product_id, sum(revenue_amount) as revenue_amount')
                               .from(unified_revenues, :revenues).group('revenues.account_dimension_id, revenues.company_id, revenues.product_id')
  end

  private

  def unified_revenues
    [content_fee_revenues, display_products_monthly_revenues, display_products_daily_revenues].inject(:union)
  end

  def content_fee_revenues
    [agency_content_fee_products_budgets, advertiser_content_fee_products_budgets].inject(&:union)
  end

  def display_products_monthly_revenues
    [agency_display_products_budgets, advertiser_display_products_budgets].inject(&:union)
  end

  def display_products_daily_revenues
    [agency_display_line_items_daily_rate_budgets, advertiser_display_line_items_daily_rate_budgets].inject(&:union)
  end

  def agency_content_fee_products_budgets
    ContentFeeProductBudget
        .select('agency_id as account_dimension_id,
                 company_id,
                 product_id,
                 SUM(revenue_amount) as revenue_amount')
        .from(content_fee_products_budgets, :cfpb)
        .where('agency_id IS NOT NULL')
        .group('agency_id, company_id, product_id')
  end

  def advertiser_content_fee_products_budgets
    ContentFeeProductBudget
        .select('advertiser_id as account_dimension_id,
                 company_id,
                 product_id,
                 sum(revenue_amount) as revenue_amount')
        .from(content_fee_products_budgets, :cfpb)
        .where('advertiser_id IS NOT NULL')
        .group('advertiser_id, company_id, product_id')
  end

  def content_fee_products_budgets
    content_fees_with_monthly_budgets
        .group('ios.advertiser_id, ios.agency_id, ios.company_id, products.id')
        .select('ios.advertiser_id as advertiser_id,
                 ios.agency_id as agency_id,
                 ios.company_id,
                 products.id as product_id,
                 SUM(ceil(content_fee_product_budgets.budget::DOUBLE PRECISION)) as revenue_amount')
  end

  def agency_display_products_budgets
    DisplayLineItemBudget.select('agency_id as account_dimension_id,
                                  company_id,
                                  product_id,
                                  sum(revenue_amount) as revenue_amount')
                         .from(display_products_budgets, :dlib)
                         .where('agency_id IS NOT NULL')
                         .group('agency_id, company_id, product_id')
  end

  def advertiser_display_products_budgets
    DisplayLineItemBudget.select('advertiser_id as account_dimension_id,
                                  company_id,
                                  product_id,
                                  SUM(revenue_amount) as revenue_amount')
                         .from(display_products_budgets, :dlib)
                         .where('advertiser_id IS NOT NULL')
                         .group('advertiser_id, company_id, product_id')
  end

  def display_products_budgets
    lines_with_monthly_budgets
        .group('ios.advertiser_id, ios.agency_id, ios.company_id, products.id')
        .select('ios.advertiser_id as advertiser_id,
                ios.agency_id as agency_id,
                ios.company_id,
                products.id as product_id,
                SUM(ceil(display_line_item_budgets.budget::DOUBLE PRECISION)) as revenue_amount')
  end

  def agency_display_line_items_daily_rate_budgets
    DisplayLineItem.select('agency_id as account_dimension_id,
                            company_id,
                            product_id,
                            SUM(revenue_amount) as revenue_amount')
                   .from(display_line_items_daily_rate_budgets, :dli)
                   .where('agency_id IS NOT NULL')
                   .group('agency_id, company_id, product_id')
  end

  def advertiser_display_line_items_daily_rate_budgets
    DisplayLineItem.select('advertiser_id as account_dimension_id,
                            company_id,
                            product_id,
                            SUM(revenue_amount) as revenue_amount')
                    .from(display_line_items_daily_rate_budgets, :dli)
                    .where('advertiser_id IS NOT NULL')
                    .group('advertiser_id, company_id, product_id')
  end

  def display_line_items_daily_rate_budgets
    lines_without_monthly_budgets
        .group('ios.advertiser_id, products.id, ios.agency_id, ios.company_id')
        .select('ios.advertiser_id as advertiser_id,
                 ios.agency_id as agency_id,
                 ios.company_id,
                 products.id as product_id,
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
    ContentFeeProductBudget.joins(content_fee: [:io, :product])
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
     AND (display_line_items.id NOT IN (:display_line_item_ids) OR display_line_items.id IS NOT NULL)
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