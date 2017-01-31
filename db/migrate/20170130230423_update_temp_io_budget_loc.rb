class UpdateTempIoBudgetLoc < ActiveRecord::Migration
  def change
    TempIo.update_all('budget_loc = budget')
  end
end
