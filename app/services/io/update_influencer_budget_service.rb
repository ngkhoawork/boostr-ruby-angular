class Io::UpdateInfluencerBudgetService
  def initialize(io)
    @io               = io
    @company          = io.company
  end

  def perform
    update_influencer_budget
  end

  private

  attr_reader :io,
              :company

  def update_influencer_budget
    data = build_product_data
    update_product_budgets(data)
  end

  def build_product_data
    influencer_content_fees.inject({}) do |data, influencer_content_fee|
      content_fee_product_budget = influencer_content_fee
                                      .content_fee
                                      .content_fee_product_budgets
                                      .for_year_month(influencer_content_fee.effect_date)
                                      .try(:first)
      if content_fee_product_budget
        data[content_fee_product_budget.id] ||= 0
        data[content_fee_product_budget.id] += influencer_content_fee.gross_amount.to_f
      end
      data
    end
  end

  def update_product_budgets(data)
    data.each do |id, budget|
      content_fee_product_budget = io.content_fee_product_budgets.find(id)
      if content_fee_product_budget && content_fee_product_budget.update_budget!(budget)
        content_fee_product_budget.content_fee.update_budget
        content_fee_product_budget.content_fee.io.update_total_budget
      end
    end
  end


  def start_date
    @_start_date ||= io.start_date
  end

  def end_date
    @_end_date ||= io.end_date
  end

  def influencer_content_fees
    @_influencer_content_fees ||= io
      .influencer_content_fees
      .by_effect_date(start_date, end_date)
  end
end
