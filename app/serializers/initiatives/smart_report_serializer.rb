class Initiatives::SmartReportSerializer < ActiveModel::Serializer
  attributes :id, :name, :goal, :pipeline, :won, :goal_probability, :chart_data

  def pipeline
    @_pipeline ||= deals.open.inject(0) do |budgets_sum, deal|
      budgets_sum += deal.budget * deal.stage.probability / 100
    end.to_i
  end

  def won
    @_won ||= deals.won.inject(0) do |budgets_sum, deal|
      budgets_sum += deal.budget
    end.to_i
  end

  def goal_probability
    return 'N/A' if goal.nil? || goal.to_f == 0
    (pipeline + won) / (goal / 100)
  end

  def chart_data
    open_budget.merge(closed_won_budget)
  end

  def closed_won_budget
    { '100' => calculate_closed_won_budget }
  end

  def calculate_closed_won_budget
    deals.closed.won.inject(0) do |budgets_sum, deal|
      budgets_sum += deal.budget
    end.to_i
  end

  def open_budget
    calculate_open_budget.each do |key, value|
      calculate_open_budget[key] = value.to_i
    end
  end

  def calculate_open_budget
    @_open_budget ||= deals.grouped_open_by_probability_sum
  end

  def deals
    @_deals ||= object.deals
  end
end
