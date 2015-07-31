class AddStageToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :stage_id, :integer
    remove_column :deals, :stage, :string
  end
end
