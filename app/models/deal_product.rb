class DealProduct < ActiveRecord::Base
  belongs_to :deal
  belongs_to :product

  before_update do
    self.budget = budget * 100 if budget_changed?
  end

  after_update do
    deal.update_total_budget
  end
end
