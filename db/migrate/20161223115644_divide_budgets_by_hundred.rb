class DivideBudgetsByHundred < ActiveRecord::Migration
  def up
    Deal.where('budget > 0').update_all('budget = budget / 100')
    DealProduct.where('budget > 0').update_all('budget = budget / 100')
    DealProductBudget.where('budget > 0').update_all('budget = budget / 100')
  end

  def down
    Deal.where('budget > 0').update_all('budget = budget * 100')
    DealProduct.where('budget > 0').update_all('budget = budget * 100')
    DealProductBudget.where('budget > 0').update_all('budget = budget * 100')
  end
end
