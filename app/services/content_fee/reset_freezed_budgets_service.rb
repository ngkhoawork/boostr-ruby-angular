class ContentFee::ResetFreezedBudgetsService
  def initialize(content_fee)
    @content_fee      = content_fee
    @io               = content_fee.io
  end

  def perform
    generate_new_budgets
    remove_old_budgets
    reset_edge_products_date
    content_fee.update_budget
  end

  private

  attr_reader :io,
              :content_fee

  def generate_new_budgets
    front_new_months.each do |month|
      create_empty_budget(month)
    end
    end_new_months.each do |month|
      create_empty_budget(month)
    end
  end

  def remove_old_budgets
    front_old_months.each do |month|
      remove_budget(month)
    end
    end_old_months.each do |month|
      remove_budget(month)
    end
  end

  def reset_edge_products_date
    start_edge_date = [first_product_date, start_date].max
    end_edge_date = [end_product_date, end_date].min
    first_budget = content_fee_product_budgets.for_year_month(start_edge_date)&.first
    end_budget = content_fee_product_budgets.for_year_month(end_edge_date)&.first

    reset_budget_date(first_budget) if first_budget
    reset_budget_date(end_budget) if end_budget
  end

  def reset_budget_date(budget_item)
    budget_item.start_date = [budget_item.start_date.beginning_of_month, start_date].max
    budget_item.end_date = [budget_item.end_date.end_of_month, end_date].min
    budget_item.save
  end

  def remove_budget(month)
    content_fee_product_budgets.for_year_month(month).destroy_all
  end

  def create_empty_budget(month)
    content_fee_product_budgets.create(
      start_date: [month, start_date].max,
      end_date:   [month.end_of_month, end_date].min,
      budget:     0,
      budget_loc: 0
    )
  end

  def start_date
    @_start_date ||= io.start_date
  end

  def end_date
    @_end_date ||= io.end_date
  end

  def content_fee_product_budgets
    content_fee.content_fee_product_budgets.by_oldest
  end

  def first_product_date
    @_first_product_date ||= content_fee_product_budgets.first.start_date
  end

  def end_product_date
    @_end_product_date ||= content_fee_product_budgets.last.end_date
  end

  def front_new_months
    @_front_new_months ||= months(start_date, first_product_date.prev_month.end_of_month)
  end

  def end_new_months
    @_end_new_months ||= months(end_product_date.next_month.beginning_of_month, end_date)
  end

  def front_old_months
    @_front_old_months ||= months(first_product_date, start_date.prev_month.end_of_month)
  end

  def end_old_months
    @_end_old_months ||= months(end_date.next_month.beginning_of_month, end_product_date)
  end

  def months(s_date, e_date)
    (s_date..e_date).map{ |d| d.beginning_of_month }.uniq
  end
end
