class AddIsEstimateToCost < ActiveRecord::Migration
  def change
    add_column :costs, :is_estimated, :boolean, default: false
  end
end
