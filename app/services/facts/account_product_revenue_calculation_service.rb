class Facts::AccountProductRevenueCalculationService < BaseService

  def calculate_revenues
    merged_budgets
  end

  def remove_unused_records
    unused_records.delete_all
  end

  private

  def unused_records
    return existing_revenue_facts unless merged_budgets.any?
    existing_revenue_facts.where('product_dimension_id not in (:ids)', ids: merged_budgets.keys)
  end

  def existing_revenue_facts
    @existing_revenue_facts ||= AccountProductRevenueFact.where('account_dimension_id = :account_id
                                                                 AND time_dimension_id = :time_dimension_id
                                                                 AND company_id = :company_id',
                                                                 account_id: account_id,
                                                                 time_dimension_id: time_dimension_id,
                                                                 company_id: company_id)
  end

  def time_dimension_id
    TimeDimension.where(start_date: date_range[:start_date],
                        end_date: date_range[:end_date]).pluck(:id)
  end

  def merged_budgets
    @merged_budgets ||= all_budgets.inject(&:merge)
  end

  def all_budgets
    [content_fee_products_budgets, display_products_budgets, display_line_item_budgets_daily_rate]
  end

  def content_fee_products_budgets
    @content_fee_products_budgets ||= ContentFeeProductBudget.joins(content_fee: :product)
                                                             .joins('INNER JOIN companies ON products.company_id = companies.id')
                                                             .joins('INNER JOIN ios on ios.id = content_fees.io_id')
                                                             .where(content_fee_products_budgets_conditions,
                                                                    account_id: account_id,
                                                                    company_id: company_id,
                                                                    time_dim_start_date: date_range[:start_date],
                                                                    time_dim_end_date: date_range[:end_date])
                                                             .group('products.id')
                                                             .sum(:budget)
  end

  def display_products_budgets
    @display_products_budgets ||= DisplayLineItemBudget.joins(display_line_item: :product)
                                                       .joins('INNER JOIN companies ON products.company_id = companies.id')
                                                       .joins('INNER JOIN ios on ios.id = display_line_items.io_id')
                                                       .where(display_products_budgets_conditions,
                                                              company_id: company_id,
                                                              account_id: account_id,
                                                              time_dim_start_date: date_range[:start_date],
                                                              time_dim_end_date: date_range[:end_date])
                                                       .group('products.id')
                                                       .sum(:budget)
  end

  def display_line_item_budgets_daily_rate
    @display_line_item_budgets_daily_rate ||= DisplayLineItem.joins(product: :company)
                                                             .joins('INNER JOIN ios on ios.id = display_line_items.io_id')
                                                             .where(display_line_item_budgets_daily_rate_conditions,
                                                                    company_id: company_id,
                                                                    account_id: account_id,
                                                                    product_ids: display_products_budgets.keys,
                                                                    time_dim_start_date: date_range[:start_date],
                                                                    time_dim_end_date: date_range[:end_date])
                                                             .group(:product_id)
                                                             .sum(:daily_run_rate)
  end

  def content_fee_products_budgets_conditions
    'content_fee_product_budgets.end_date >= :time_dim_start_date
     AND content_fee_product_budgets.start_date <= :time_dim_end_date
     AND ios.company_id = :company_id
     AND ios.advertiser_id = :account_id OR ios.agency_id = :account_id'
  end

  def display_line_item_budgets_daily_rate_conditions
    'display_line_items.end_date >= :time_dim_start_date
     AND display_line_items.start_date <= :time_dim_end_date
     AND products.revenue_type = \'Display\'
     AND products.id NOT IN (:product_ids)
     AND ios.company_id = :company_id
     AND ios.advertiser_id = :account_id OR ios.agency_id = :account_id'
  end

  def display_products_budgets_conditions
    'display_line_item_budgets.end_date >= :time_dim_start_date
     AND display_line_item_budgets.start_date <= :time_dim_end_date
     AND products.revenue_type = \'Display\'
     AND ios.company_id = :company_id
     AND ios.advertiser_id = :account_id OR ios.agency_id = :account_id'
  end

end