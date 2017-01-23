class MultiCurrencyColumns < ActiveRecord::Migration
  def change
    # Currency type identificator
    add_column :deals, :curr_cd, :string, default: 'USD'
    # add_column :deal_products, :curr_cd, :string
    # add_column :deal_product_budgets, :curr_cd, :string
    # add_column :ios, :curr_cd, :string
    # add_column :content_fees, :curr_cd, :string
    # add_column :content_fee_product_budgets, :curr_cd, :string
    add_column :quota, :curr_cd, :string
    # add_column :display_line_items, :curr_cd, :string
    # add_column :display_line_item_budgets, :curr_cd, :string

    # Budget in the local currency
    add_column :deals, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :deal_products, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :deal_product_budgets, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :deal_logs, :budget_change_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :ios, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :content_fees, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :content_fee_product_budgets, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :quota, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :display_line_items, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :display_line_item_budgets, :budget_loc, :decimal, precision: 15, scale: 2, default: 0

    # Display Line Item budget in local currency
    add_column :display_line_items, :budget_delivered_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :display_line_items, :budget_remaining_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :display_line_items, :budget_delivered_3p_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :display_line_items, :budget_remaining_3p_loc, :decimal, precision: 15, scale: 2, default: 0

    # Default User Currency
    add_column :users, :default_currency, :string, default: 'USD'

    # Set existing budget values in local currency
    Deal.update_all('budget_loc = budget')
    DealProduct.update_all('budget_loc = budget')
    DealProductBudget.update_all('budget_loc = budget')
    Io.update_all('budget_loc = budget')
    ContentFee.update_all('budget_loc = budget')
    ContentFeeProductBudget.update_all('budget_loc = budget')
    Quota.update_all('budget_loc = value')
    DisplayLineItem.update_all('budget_loc = budget')
    DisplayLineItemBudget.update_all('budget_loc = budget')

    # Set existing Display Line Item budgets in local currency
    DisplayLineItem.update_all('budget_delivered_loc = budget_delivered')
    DisplayLineItem.update_all('budget_remaining_loc = budget_remaining')
    DisplayLineItem.update_all('budget_delivered_3p_loc = budget_delivered_3p')
    DisplayLineItem.update_all('budget_remaining_3p_loc = budget_remaining_3p')
  end
end
