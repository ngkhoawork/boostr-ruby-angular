class AddNextStepsDueToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :next_steps_due, :datetime
  end
end
