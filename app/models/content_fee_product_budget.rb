class ContentFeeProductBudget < ActiveRecord::Base
  belongs_to :content_fee

  def daily_budget
    budget / (end_date - start_date + 1).to_i
  end
end
