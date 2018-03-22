class Cost::ResetFreezedAmountsService
  def initialize(cost)
    @cost      = cost
    @io        = cost.io
  end

  def perform
    update_all_budgets
  end

  private

  attr_reader :io,
              :cost

  def update_all_budgets
    generate_new_amounts
    remove_old_amounts
    reset_edge_amounts_date
    cost.update_budget
  end

  def generate_new_amounts
    front_new_months.each do |month|
      create_empty_amount(month)
    end
    end_new_months.each do |month|
      create_empty_amount(month)
    end
  end

  def remove_old_amounts
    front_old_months.each do |month|
      remove_amount(month)
    end
    end_old_months.each do |month|
      remove_amount(month)
    end
  end

  def reset_edge_amounts_date
    start_edge_date = [first_amount_date, start_date].max
    end_edge_date = [end_amount_date, end_date].min
    first_amount = cost_monthly_amounts.for_year_month(start_edge_date)&.first
    end_amount = cost_monthly_amounts.for_year_month(end_edge_date)&.first
    reset_amount_date(first_amount) if first_amount
    reset_amount_date(end_amount) if end_amount
  end

  def reset_amount_date(budget_item)
    budget_item.update(
      start_date: [budget_item.start_date.beginning_of_month, start_date].max,
      end_date: [budget_item.end_date.end_of_month, end_date].min
    )
  end

  def remove_amount(month)
    cost_monthly_amounts.for_year_month(month).destroy_all
  end

  def create_empty_amount(month)
    cost_monthly_amounts.create(
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

  def cost_monthly_amounts
    cost.cost_monthly_amounts.by_oldest
  end

  def first_amount_date
    @_first_amount_date ||= cost_monthly_amounts.first.start_date
  end

  def end_amount_date
    @_end_amount_date ||= cost_monthly_amounts.last.end_date
  end

  def front_new_months
    @_front_new_months ||= months(start_date, first_amount_date.prev_month.end_of_month)
  end

  def end_new_months
    @_end_new_months ||= months(end_amount_date.next_month.beginning_of_month, end_date)
  end

  def front_old_months
    @_front_old_months ||= months(first_amount_date, start_date.prev_month.end_of_month)
  end

  def end_old_months
    @_end_old_months ||= months(end_date.next_month.beginning_of_month, end_amount_date)
  end

  def months(s_date, e_date)
    (s_date..e_date).map{ |d| d.beginning_of_month }.uniq
  end
end
